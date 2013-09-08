/*global module:false*/

var fs = require('fs');

function endsWith(src, suffix) {
    return src.indexOf(suffix, src.length - suffix.length) !== -1;
}

var filelist = fs.readdirSync('./coffee-dist').filter(function(filename) {
    debugger;
    if(endsWith(filename, ".js") && (!endsWith(filename, ".min.js"))) {
        return true;
    }
    return false;
    }),
    minify_files = {};

filelist.forEach(function(filename) {
    minify_files["coffee-dist/" + filename.replace(/\.js$/, ".min.js")] = ["coffee-dist/" + filename];
});

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    // Metadata.
    pkg: grunt.file.readJSON('package.json'),
    banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
      '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
      '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
      '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
      ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n',
    // Task configuration.
    coffee: {
        glob_to_multiple: {
            options: {
                sourceMap: true
            }, 
            expand: true,
            flatten: true,
            cwd: 'coffee/', 
            src: ['*.coffee'], 
            dest: 'coffee-dist/', 
            ext: '.js'
        }
    }, 
    watch: {
        files: ['coffee/*.coffee'], 
        tasks: ['coffee', 'uglify']
    }, 
    uglify: {
        minify: {
            options: {
                sourceMap: function(fn) { return fn + ".map";},
                sourceMapRoot: "/",
                sourceMapPrefix: "/",
                sourceMappingURL: function(url) { return "/" + url + ".map";}
            },
            files: minify_files
            /* {
                'coffee-dist/player-main.min.js'  : ['coffee-dist/player-main.js'], 
                'coffee-dist/player-lastfm.min.js' : ['coffee-dist/player-lastfm.js'],
                'coffee-dist/player-setting.min.js' : ['coffee-dist/player-setting.js'],
                'coffee-dist/player-keybinding.min.js' : ['coffee-dist/player-keybinding.js'],
                'coffee-dist/player-player.min.js' : ['coffee-dist/player']
                'coffee-dist/douban-fm-login.min.js' : ['coffee-dist/douban-fm-login.js'], 
                'coffee-dist/lastfm-login.min.js' : ['coffee-dist/lastfm-login.js']
            }*/
        }
    }
  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  // Default task.
  grunt.registerTask('default', ['coffee', 'uglify']);

};
