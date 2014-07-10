module.exports = (grunt) ->

  copyTargets = [
    { expand: true, cwd: 'src', src: ['**', '!**/*.coffee'], dest: 'build' }
  ]

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    copy:
      build:
        files: copyTargets
    clean:
      build:
        [ 'build' ]
    coffee:
      lib:
        files: [
          expand: true
          cwd: 'src'
          src: ['**/*.coffee']
          dest: 'build'
          ext: '.js'
        ]
    watch:
      all:
        files: [
          'Gruntfile.coffee'
          'src/**/*'
          'package.json'
        ]
        tasks: ["build"]
        options:
          spawn: false
    notify:
      complete:
        options:
          title: 'Project Compiled',  # optional
          message: 'Project has been compiled', #required


  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-notify'

  grunt.registerTask 'default', 'Compiles all of the assets and copies the files to the build directory.', [ 'init-atom', 'build' ]
  grunt.registerTask 'build', 'Builds the application', [
    'clean:build',
    'coffee',
    'copy',
    'notify:complete'
  ]
