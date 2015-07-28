progeny = require('../dest/parse')
path = require('path')
assert = require('assert')

getFixturePath = (subPath) ->
	path.join __dirname, 'fixtures', subPath

describe 'progeny', ->
	it 'should preserve original file extensions', ->
		dependencies = progeny() getFixturePath('altExtensions.jade')
		paths = (getFixturePath x for x in ['htmlPartial.html', 'htmlPartial.html.jade'])
		assert.deepEqual dependencies, paths

describe 'progeny configuration', ->
	describe 'excluded file list', ->
		progenyConfig =
			rootPath: path.join __dirname, 'fixtures'
			exclusion: [
				/excludedDependencyOne/
				/excludedDependencyTwo/
			]
			extension: 'jade'

		it 'should accept one regex', ->
			progenyConfig.exclusion = /excludedDependencyOne/
			getDependencies = progeny progenyConfig

			dependencies = getDependencies getFixturePath('excludedDependencies.jade')
			paths =  (getFixturePath x for x in ['excludedDependencyTwo.jade', 'includedDependencyOne.jade'])
			assert.deepEqual dependencies, paths

		it 'should accept one string', ->
			progenyConfig.exclusion = 'excludedDependencyOne'
			getDependencies = progeny progenyConfig

			dependencies = getDependencies getFixturePath('excludedDependencies.jade')
			paths =  (getFixturePath x for x in ['excludedDependencyTwo.jade', 'includedDependencyOne.jade'])
			assert.deepEqual dependencies, paths

		it 'should accept a list of regexes', ->
			progenyConfig.exclusion = [
				/excludedDependencyOne/
				/excludedDependencyTwo/
			]
			getDependencies = progeny progenyConfig

			dependencies = getDependencies getFixturePath('excludedDependencies.jade')
			assert.deepEqual dependencies, [getFixturePath 'includedDependencyOne.jade']

		it 'should accept a list of strings', ->
			progenyConfig.exclusion = [
				'excludedDependencyOne'
				'excludedDependencyTwo'
			]
			getDependencies = progeny progenyConfig

			dependencies = getDependencies getFixturePath('excludedDependencies.jade')
			assert.deepEqual dependencies, [getFixturePath 'includedDependencyOne.jade']

		it 'should accept a list of both strings and regexps', ->
			progenyConfig.exclusion = [
				'excludedDependencyOne'
				/excludedDependencyTwo/
			]
			getDependencies = progeny progenyConfig

			dependencies = getDependencies getFixturePath('excludedDependencies.jade')
			assert.deepEqual dependencies, [getFixturePath 'includedDependencyOne.jade']
