module.exports = (extname) ->
	switch extname

		when 'jade'
			regexp: /^\s*(?:include|extends)\s+(.+)/

		when 'jedi'
			regexp: /^\s*:import\s+(.+)/
			skip: /-^\s*--.*/

		when 'styl'
			regexp: /^\s*@import\s+['"]?([^'"]+)['"]?/
			exclusion: 'nib'

		when 'less'
			regexp: /^\s*@import\s+['"]([^'"]+)['"]/

		when 'scss', 'sass'
			skip: /\/\*.+?\*\/|\/\/.*(?=[\n\r])/
			regexp: /^\s*@import\s+['"]?([^'"]+)['"]?/
			prefix: '_'
			exclusion: /^compass/
			extensionsList: ['scss', 'sass']
