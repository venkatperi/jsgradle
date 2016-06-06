description = 'test project'
version = '0.2.0'

apply plugin : 'greeting'

defaultTasks 'hello', 't5'

greeting -> name = 'world'

task copy(type : Copy), ( t )->
  println "configuring task: #{t.name}, type: #{t.type}, path: #{t.path}"
  doFirst -> println t.name + ' 1'
  doFirst -> println t.name + ' 2'
  doLast -> println t.name + ' 3'

task t2(dependsOn : copy), ( t )->
  println "configuring task: #{t.name}, type: #{t.type}"
  doFirst -> println t.name + ' 1'

task t3(dependsOn : copy), ( t )->
  println "configuring task: #{t.name}, type: #{t.type}"
  doFirst -> println t.name + ' 1'

task t4(dependsOn : t3), ( t )->
  println "configuring task: #{t.name}, type: #{t.type}"
  doFirst -> println t.name + ' 1'

task t5(dependsOn : [ t4, t2 ]), ( t )->
  println "configuring task: #{t.name}, type: #{t.type}"
  doFirst -> println t.name + ' 1'

