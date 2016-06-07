module.exports = (extname) ->
	switch extname

		when 'jade'
			regexp: /^\s*(?:include|extends)\s+(.+)/

		when 'jedi'
			regexp: /^\s*:import\s+(.+)/
			skip: /-^\s*--.*/

		when 'styl'
			regexp: /^\s*(?:@import|@require)\s+['"](.+?)['"](?:$|;)/
			directoryEntry: 'index'
			exclusion: 'nib'

		when 'less'
			regexp: /^\s*@import\s*(?:\(\w+\)\s*)?(?:(?:url\()?['"]([^'"]+)['"])/

		when 'scss', 'sass'
			skip: /\/\*.+?\*\/|\/\/.*(?=[\n\r])/
			regexp: /^\s*@import\s+['"]?([^"']+)['"]?(?:;|$)/
			prefix: '_'
			exclusion: /^compass/
			extensionsList: ['scss', 'sass']
		else
			{}
