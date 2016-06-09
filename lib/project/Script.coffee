Q = require 'q'
path = require 'path'
fs = require 'fs'
CoffeeDsl = require 'coffee-dsl'
Phase = require './ScriptPhase'
Project = require './Project'
log = require('../util/logger') 'Script'
walkup = require 'node-walkup'
SeqX = require '../util/SeqX'
{multi} = require 'heterarchy'
out = require '../util/out'

readFile = Q.denodeify fs.readFile

class Script extends multi CoffeeDsl, SeqX
  constructor : ( {@scriptFile} = {} ) ->
    throw new Error "Missing option: scriptFile" unless @scriptFile
    super()
    @symbols.println = (msg) -> out(msg).eol()
    @symbols.sleep = ( time, fn ) -> setTimeout fn, time
    @phase = Phase.Initial
    @on 'error', ( err ) =>
      console.log err
      throw err
    @seq @_loadScript

  methodMissing : ( name ) => ( args... ) =>
    log.v "method missing: #{name}, #{JSON.stringify args}"
    val = @project.methodMissing name, args...
    return val if val?
    return [ name ] unless args.length
    args = args[ 0 ] if args.length is 1
    [ name, args ]

  propertyMissing : ( name ) ->
    log.d "property missing: #{name}"
    name

  initialize : => @seq @_initialize

  configure : => @seq @_configure

  execute : => @seq @_execute

  report : => @project.report()

  logLevel : ( l ) => log.level l

  _loadScript : =>
    walkup 'build.kohi', cwd : process.cwd()
    .then ( v ) =>
      throw new Error "Didn't find file build.kohi" unless v.length
      @scriptFile = path.join v[ 0 ].dir, v[ 0 ].files[ 0 ]
      log.v 'script file:', @scriptFile
      readFile @scriptFile, 'utf8'
    .then ( contents ) =>
      @contents = contents

  _initialize : =>
    log.v 'initialize'
    @phase = Phase.Initialization
    @project = @_createProject()
    @context.push @project
    @project.initialize()

  _createProject : =>
    parts = path.parse @scriptFile
    projectDir = parts.dir
    name = path.basename projectDir
    project = new Project
      script : @
      name : name,
      projectDir : projectDir
    project

  _configure : =>
    log.v 'configure'
    @phase = Phase.Configuration
    @evaluate @contents
    @project.configure()

  _execute : =>
    log.v 'execute'
    @phase = Phase.Execution
    @project.execute()

module.exports = Script