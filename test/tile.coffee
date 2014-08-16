chai = require('chai')
sinon = require 'sinon'
sinon_chai = require 'sinon-chai'
expect = chai.expect
chai.use(sinon_chai)

Tile = require 'tile'
Board = require 'board'
fabric = require('fabric').fabric
_ = require 'underscore'
$ = require 'jquery'
describe 'Tile', ->
  beforeEach ->
    document.body.innerHTML = __html__['index.html']
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
      expect(@board.place_tile @tile).to.be.ok
      expect(@tile.x).to.not.be.undefined
      expect(@tile.y).to.not.be.undefined

    it 'should not be placed if there is no room', ->
      _(4).times =>
        tile = new Tile 'first', '1', @board.size, @board
        @board.place_tile tile
      expect(@board.place_tile @tile).to.be.false
      expect(@tile.x).to.be.undefined
      expect(@tile.y).to.be.undefined
    it 'has four rotations', ->
      expect(@tile.rotations()).to.eql [1,2,3,4]

  describe '- 2 turn tile', ->
    beforeEach ->
      @tile = new Tile 'first', '2-turn', @board.size, @board

    it 'has four rotations', ->
      expect(@tile.rotations()).to.eql [1,2,3,4]

    it 'has two exits', ->
      for orientation in [1,2,3,4]
        count = 0
        @tile.rotate(orientation)
        for exit in ['north', 'east', 'south', 'west']
          count++ if @tile[exit]
        expect(count).to.eq 2

    it 'has exits that are next to eachother', ->
      for orientation in [1,2,3,4]
        @tile.rotate(orientation)
        if @tile.north
          expect(@tile.south).to.be.false
          expect(@tile.east || @tile.west).to.be.true
        if @tile.east
          expect(@tile.west).to.be.false
          expect(@tile.south || @tile.north).to.be.true
        if @tile.south
          expect(@tile.north).to.be.false
          expect(@tile.east || @tile.west).to.be.true
        if @tile.west
          expect(@tile.east).to.be.false
          expect(@tile.south || @tile.north).to.be.true

  describe '- 2 straight tile', ->
    beforeEach ->
      @tile = new Tile 'first', '2-straight', @board.size, @board

    it 'has two rotations', ->
      expect(@tile.rotations()).to.eql [1,2]

    it 'has two exits', ->
      for orientation in [1,2]
        count = 0
        @tile.rotate(orientation)
        for exit in ['north', 'east', 'south', 'west']
          count++ if @tile[exit]
        expect(count).to.eq 2
    it 'has exits that are across from eachother', ->
      for orientation in [1,2]
        @tile.rotate(orientation)
        expect(@tile.north).to.eql @tile.south
        expect(@tile.east).to.eql @tile.west

  describe '- 3 tile', ->
    beforeEach ->
      @tile = new Tile 'first', '3', @board.size, @board

    it 'has four rotations', ->
      expect(@tile.rotations()).to.eql [1,2,3,4]

    it 'has three exits', ->
      for orientation in [1,2,3,4]
        count = 0
        @tile.rotate(orientation)
        for exit in ['north', 'east', 'south', 'west']
          count++ if @tile[exit]
        expect(count).to.eq 3

  describe '- 4 tile', ->
    beforeEach ->
      @tile = new Tile 'first', '4', @board.size, @board

    it 'has one rotations', ->
      expect(@tile.rotations()).to.eql [1]

    it 'has four exits', ->
      expect(@tile.north).to.be.true
      expect(@tile.east).to.be.true
      expect(@tile.south).to.be.true
      expect(@tile.west).to.be.true

  describe 'toggling', ->
    beforeEach ->
      @board.add_start_tile()
      @tile = @board.tiles[0][0]

    it 'should set toggled', ->
      expect(@tile.toggled).to.be.undefined
      @tile.toggle()
      expect(@tile.toggled).to.be.true
      @tile.toggle()
      expect(@tile.toggled).to.be.false

    it 'should untoggle others', ->
      tile = new Tile 'first', '1', @board.size, @board
      @board.place_tile tile
      expect(@tile.toggled).to.be.undefined
      expect(tile.toggled).to.be.undefined
      @tile.toggle()
      expect(@tile.toggled).to.be.true
      tile.toggle()
      expect(tile.toggled).to.be.true
      expect(@tile.toggled).to.be.false

    it 'should redraw', ->
      sinon.spy(@tile, 'redraw')
      @tile.toggle()
      expect(@tile.redraw).to.have.been.calledOnce

  describe 'neighbors', ->
    beforeEach ->
      @board.add_start_tile()
      @start = @board.tiles[0][0]
      for coords in [[1,0], [0,1], [-1,0], [0,-1]]
        tile = new Tile 'first', '4', @board.size, @board
        @board.add_tile(tile, coords[0], coords[1])

    it 'start should have neighbors in all directions', ->
      expect(@start.neighbor_to_the('north')).to.be.ok
      expect(@start.neighbor_to_the('east')).to.be.ok
      expect(@start.neighbor_to_the('south')).to.be.ok
      expect(@start.neighbor_to_the('west')).to.be.ok

    it 'north of start', ->
      tile = @start.neighbor_to_the('north')
      expect(tile.neighbor_to_the('north')).to.be.false
      expect(tile.neighbor_to_the('east')).to.be.false
      expect(tile.neighbor_to_the('south')).to.be.ok
      expect(tile.neighbor_to_the('west')).to.be.false
      
    it 'east of start', ->
      tile = @start.neighbor_to_the('east')
      expect(tile.neighbor_to_the('north')).to.be.false
      expect(tile.neighbor_to_the('east')).to.be.false
      expect(tile.neighbor_to_the('south')).to.be.false
      expect(tile.neighbor_to_the('west')).to.be.ok
      
    it 'south of start', ->
      tile = @start.neighbor_to_the('south')
      expect(tile.neighbor_to_the('north')).to.be.ok
      expect(tile.neighbor_to_the('east')).to.be.false
      expect(tile.neighbor_to_the('south')).to.be.false
      expect(tile.neighbor_to_the('west')).to.be.false
      
    it 'west of start', ->
      tile = @start.neighbor_to_the('west')
      expect(tile.neighbor_to_the('north')).to.be.false
      expect(tile.neighbor_to_the('east')).to.be.ok
      expect(tile.neighbor_to_the('south')).to.be.false
      expect(tile.neighbor_to_the('west')).to.be.false
      
  describe 'exits', ->
    it 'should have tests'
