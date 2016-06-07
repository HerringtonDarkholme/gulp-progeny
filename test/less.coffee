lessReg = require('../dest/setting')('less').regexp
assert = require('assert')

describe 'progeny less', ->
	it 'should parse less dep', ->
		path = lessReg.exec('@import (reference) "Mixins/_mixins.less";')
		assert.equal path[1], "Mixins/_mixins.less"
	it 'should parse css dep', ->
		path = lessReg.exec('@import url("Mixins/_mixins.less");')
		assert.equal path[1], "Mixins/_mixins.less"

