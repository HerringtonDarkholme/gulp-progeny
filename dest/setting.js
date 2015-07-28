module.exports = function(extname) {
  switch (extname) {
    case 'jade':
      return {
        regexp: /^\s*(?:include|extends)\s+(.+)/
      };
    case 'jedi':
      return {
        regexp: /^\s*:import\s+(.+)/,
        skip: /-^\s*--.*/
      };
    case 'styl':
      return {
        regexp: /^\s*(?:@import|@require)\s+['"](.+?)['"](?:$|;)/,
        directoryEntry: 'index',
        exclusion: 'nib'
      };
    case 'less':
      return {
        regexp: /^\s*@import\s+['"]([^'"]+)['"]/
      };
    case 'scss':
    case 'sass':
      return {
        skip: /\/\*.+?\*\/|\/\/.*(?=[\n\r])/,
        regexp: /^\s*@import\s+['"]?([^"']+)['"]?(?:;|$)/,
        prefix: '_',
        exclusion: /^compass/,
        extensionsList: ['scss', 'sass']
      };
    default:
      return {};
  }
};
