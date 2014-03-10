assert = require('chai').assert
Tile = require 'tile'
$ = require 'jquery-1.10.2'
describe 'Tile', ->
  describe 'start tile', ->
    beforeEach ->
      console.log $('#my_canvas')
      console.log '111'
      canvas = document.getElementById('my_canvas')
      console.log canvas
      console.log '222'
      context = canvas.getContext('2d')
      console.log '333'
      board = new Board context, size, [], selected_zones, interval
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
      console.log $('#my_canvas')
      assert.isFalse(@tile.neighbor_to_the('north'))
      assert.isFalse(@tile.neighbor_to_the('east'))
      assert.isFalse(@tile.neighbor_to_the('south'))
      assert.isFalse(@tile.neighbor_to_the('west'))


