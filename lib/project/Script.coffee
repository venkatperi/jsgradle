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

readFile = Q.denodeify fs.readFile

class Script extends multi CoffeeDsl, SeqX
  constructor : ( {@scriptFile} = {} ) ->
    throw new Error "Missing option: scriptFile" unless @scriptFile
    super()
    @symbols.sleep = ( time, fn ) -> setTimeout fn, time
    @phase = Phase.Initial
    @on 'error', ( err ) =>
      console.log err
      throw err
    @_seq @_loadScript

  methodMissing : ( name ) => ( args... ) =>
    log.d "method missing: #{name}, #{JSON.stringify args}"
    val = @project.methodMissing name, args...
    return val if val?
    return [ name ] unless args.length
    args = args[ 0 ] if args.length is 1
    [ name, args ]

  propertyMissing : ( name ) ->
    log.d "property missing: #{name}"
    name

  initialize : => @_seq @_initialize
  configure : => @_seq @_configure
  execute : => @_seq @_execute

  _loadScript : =>
    log.v 'loadScript:', @scriptFile
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
    project = new Project
      script : @
      name : parts.name,
      projectDir : parts.dir,
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