expect = require('chai').expect
Tile = require 'tile'
Board = require 'board'
fabric = require('fabric').fabric
_ = require 'underscore'
$ = require 'jquery'
describe 'Tile', ->
  before ->
    document.body.innerHTML = __html__['index.html']
    #canvas = document.getElementById('my_canvas')
    #context = canvas.getContext('2d')
    canvas = new fabric.StaticCanvas('my_canvas')
    selected_zones = ['first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth']
    interval = 0
    @board = new Board canvas, 60, [], selected_zones, interval
  describe 'start tile', ->
    beforeEach ->
      @tile = new Tile 'start', '4', @board.size, @board

    it 'basic info', ->
      expect(@tile.zone).to.equal('start')
      expect(@tile.x).to.equal(0)
      expect(@tile.y).to.equal(0)
    it 'has four exits', ->
      expect(@tile.north).to.be.true
      expect(@tile.east).to.be.true
      expect(@tile.south).to.be.true
      expect(@tile.west).to.be.true
    it 'has no neighbors', ->
      expect(@tile.neighbor_to_the('north')).to.be.false
      expect(@tile.neighbor_to_the('east')).to.be.false
      expect(@tile.neighbor_to_the('south')).to.be.false
      expect(@tile.neighbor_to_the('west')).to.be.false
    it 'has four exits', ->
      expect(@tile.exit_list()).to.equal('N, E, S, W')
    it 'has four empty exits', ->
      expect(@tile.empty_exits()).to.equal('N, E, S, W')
  describe '- 1 tile', ->
    beforeEach ->
      @board.add_start_tile()
      @tile = new Tile 'first', '1', @board.size, @board

    it 'basic info', ->
      expect(@tile.zone).to.equal('first')
      expect(@tile.x).to.be.undefined
      expect(@tile.y).to.be.undefined

    it 'should be placed', ->
      expect(@tile.place()).to.be.ok
      expect(@tile.x).to.not.be.undefined
      expect(@tile.y).to.not.be.undefined


    it 'should not be placed if there is no room', ->
      _(4).times =>
        tile = new Tile 'first', '1', @board.size, @board
        tile.place()
      expect(@tile.place()).to.be.false
      expect(@tile.x).to.be.undefined
      expect(@tile.y).to.be.undefined
      


