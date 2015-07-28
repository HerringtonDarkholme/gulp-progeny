progeny = require('../dest/parse')
path = require('path')
assert = require('assert')

getFixturePath = (subPath) ->
	path.join __dirname, 'fixtures', subPath

describe 'progeny stylus', ->
	it 'stylus glob import', ->
		getDependencies = progeny()
		dependencies = getDependencies getFixturePath('test.styl')
		paths = (getFixturePath "styl/#{x}.styl" for x in ['a', 'b'])
		assert.deepEqual dependencies, paths

	it 'stylus directory import', ->
		getDependencies = progeny()
		dependencies = getDependencies getFixturePath('importDir.styl')
		paths = [getFixturePath 'dir/index.styl']
		assert.deepEqual dependencies, paths
