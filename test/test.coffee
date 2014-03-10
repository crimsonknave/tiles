assert = require('chai').assert
Tile = require 'tile'
describe 'Tile', ->
  describe 'start tile', ->
    beforeEach ->
      #board = new Board context, size, [], selected_zones, interval
      @tile = new Tile 'start', '4', @size, this #board

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


