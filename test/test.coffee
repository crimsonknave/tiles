assert = require('chai').assert
Tile = require 'tile'
describe 'Tile', ->
  describe 'start tile', ->
    it 'basic info', ->
      tile = new Tile 'start', '4', @size, this

      assert.equal(tile.zone, 'start')
      assert.equal(tile.x, 0)
      assert.equal(tile.y, 0)
