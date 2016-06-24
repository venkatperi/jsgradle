Plugin = require './Plugin'
rek = require 'rekuire'
ClearCacheTask = rek 'ClearCacheTask'

class FileCachePlugin extends Plugin

  doApply : =>
    @applyPlugin 'build'

    @register
      taskFactory :
        clearCache : ClearCacheTask
        
    @task('clean').dependsOn 'clearCache'

module.exports = FileCachePlugin