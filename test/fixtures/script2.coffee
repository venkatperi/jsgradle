description = 'test project'
version = '0.2.0'

apply plugin : 'greeting'
#apply plugin : 'package'

defaultTasks 'hello'
#defaultTasks 'hello', 'pkg', 't5'

greeting ->
  name = 'world'

###
pkg ->
  description = 'abc'

task copy(type : Copy), ( t, p )->
  println "configuring task: #{t.name}, type: #{t.type}, path: #{t.path}"

  from '../../lib', ->
    include '**/*.coffee'
    exclude '**/T*.coffee'

  into 'dist'
  exclude '**/*.bak'

  doFirst ->
    println t.name + ' 1'
    done()

  doFirst ->
    println t.name + ' 2'
    done()

  doLast ->
    println t.name + ' 3'
    done()

  p.done()

task t2(dependsOn : copy), ( t )->
  println "configuring task: #{t.name}, type: #{t.type}"
  doFirst ->
    println t.name + ' 1'
    done()
  done()

task t3(dependsOn : copy), ( t )->
  println "configuring task: #{t.name}, type: #{t.type}"
  doFirst ->
    println t.name + ' 1'
    done()
  done()

task t4(dependsOn : t3), ( t )->
  println "configuring task: #{t.name}, type: #{t.type}"
  doFirst ->
    println t.name + ' 1'
    done()
  done()

task t5(dependsOn : [ t4, t2 ]), ( t )->
  println "configuring task: #{t.name}, type: #{t.type}"
  doFirst ->
    println t.name + ' 1'
    done()
  done()
###
