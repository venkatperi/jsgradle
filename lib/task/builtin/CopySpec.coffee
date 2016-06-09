SourceSpec = require '../SourceSpec'
TargetSpec = require '../TargetSpec'
ProcessingSpec = require '../ProcessingSpec'
{multi} = require 'heterarchy'

class CopySpec extends multi SourceSpec, TargetSpec, ProcessingSpec

module.exports = CopySpec