assert = require('chai').assert
Tile = require 'tile'
Board = require 'board'
$ = require 'jquery-1.10.2'
describe 'Tile', ->
  describe 'start tile', ->
    beforeEach ->
      document.body.innerHTML = __html__['index.html']
      canvas = document.getElementById('my_canvas')
      context = canvas.getContext('2d')
      selected_zones = ['first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth']
      interval = 0
      board = new Board context, 60, [], selected_zones, interval
      @tile = new Tile 'start', '4', @size, board

    it 'basic info', ->
      assert.equal(@tile.zone, 'start')
      assert.equal(@tile.x, 0)
      assert.equal(@tile.y, 0)
    it 'has four exits', ->
      assert.isTrue(@tile.north)
      assert.isTrue(@tile.east)
      assert.isTrue(@tile.south)
      assert.isTrue(@tile.west)
    it 'has no neighbors', ->
      assert.isFalse(@tile.neighbor_to_the('north'))
      assert.isFalse(@tile.neighbor_to_the('east'))
      assert.isFalse(@tile.neighbor_to_the('south'))
      assert.isFalse(@tile.neighbor_to_the('west'))


