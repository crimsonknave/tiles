module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-haml'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-karma'
  grunt.loadNpmTasks 'grunt-newer'
  grunt.initConfig {
    pkg: grunt.file.readJSON('package.json'),
    watch: {
      haml: {
        files: ['**/*.haml']
        tasks: ['newer:haml', 'karma:unit:run']
      },
      coffee: {
        files: ['scripts/*.coffee', 'test/*.coffee']
        tasks: ['browserify', 'karma:unit:run']
      }
      sass: {
        files: ['style.scss'],
        tasks: ['sass']
      }
    },
    karma: {
      unit: {
        configFile: 'karma.conf.js',
        background: true
      }
    },
    sass: {
      dist: {
        src: 'style.scss',
        dest: 'css/style.css'
      }
    },
    haml: {
      index: {
        src: 'index.html.haml',
        dest: 'index.html'
        options: {
          language: 'ruby'
        }
      },
      templates: {
        files: [{
          expand: true,
          src: ['templates/*.haml'],
          ext: '.html'
        }]
        options: {
          language: 'ruby'
        }
      }
    },
    browserify: {
      dist: {
        files: {
          'scripts/bundle.js': ['scripts/*.coffee'],
          'test/bundle.js': ['test/*.coffee']
        },
        options: {
          transform: ['coffeeify'],
          fullPaths: true,
          aliasMappings: {
            cwd: 'scripts',
            src: ['**/*.coffee', '**/*.js', '!bundle.js']
          }
        }
      }
    }
  }
  grunt.registerTask 'default', ['karma', 'watch']
