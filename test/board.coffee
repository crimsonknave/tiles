chai = require('chai')
sinon = require 'sinon'
sinon_chai = require 'sinon-chai'
expect = chai.expect
chai.use(sinon_chai)

Board = require 'board'
Tile = require 'tile'
_ = require 'underscore'
$ = require 'jquery'

close_all_but_east = (board) ->
  board.add_start_tile()
  ends = []
  _(3).times ->
    ends.push(new Tile 'first', '1', 60, board)

  # north of start
  tile = ends.pop()
  tile.rotate 4
  expect(board.add_tile(tile, 0, 1)).to.not.be.false
  # south of start
  tile = ends.pop()
  tile.rotate 2
  expect(board.add_tile(tile, 0, -1)).to.not.be.false
  # west of start
  tile = ends.pop()
  tile.rotate 3
  expect(board.add_tile(tile, -1, 0)).to.not.be.false

create_box = (board)->
  board.add_start_tile()
  turns = []
  straight = []
  _(4).times ->
    turns.push(new Tile 'first', '2-turn', 60, board)
  _(3).times ->
    straight.push(new Tile 'first', '2-straight', 60, board)

  #2-turn 0,-1
  tile = turns.pop()
  tile.rotate 3
  board.add_tile(tile, 0, -1)
  #2-straight -1,-1
  tile = straight.pop()
  tile.rotate 1
  board.add_tile(tile, -1, -1)
  #2-turn -2,-1
  tile = turns.pop()
  tile.rotate 4
  board.add_tile(tile, -2, -1)
  #2-straight, -2,0
  tile = straight.pop()
  tile.rotate 2
  board.add_tile(tile, -2, 0)
  #2-turn -2,1
  tile = turns.pop()
  tile.rotate 1
  board.add_tile(tile, -2, 1)
  #2-straight -1,1
  tile = straight.pop()
  tile.rotate 1
  board.add_tile(tile, -1, 1)
  #2-turn 0,1
  tile = turns.pop()
  tile.rotate 2
  board.add_tile(tile, 0, 1)
  #1 1,0
  tile = new Tile 'first', '1', 60, board
  tile.rotate 1
  board.add_tile(tile, 1, 0)

describe 'Board', ->
  before ->
    document.body.innerHTML = __html__['index.html']
    canvas = document.getElementById('my_canvas')
    @context = canvas.getContext('2d')
    @selected_zones = ['first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth']
    @interval = 0
    @board = new Board @context, 60, [], @selected_zones, @interval

  describe 'basics', ->
    describe 'size 121', ->
      beforeEach ->
        @board = new Board @context, 121, [], @selected_zones, @interval

      it 'should have walls past 16', ->
        expect(@board.wall_at(9, 0)).to.be.true
        expect(@board.wall_at(0,9)).to.be.true
        expect(@board.wall_at(-9, 0)).to.be.true
        expect(@board.wall_at(0,-9)).to.be.true
        expect(@board.wall_at(0,0)).to.be.false

    describe 'size 60', ->
      it 'should have walls past 16', ->
        expect(@board.wall_at(17, 0)).to.be.true
        expect(@board.wall_at(0,17)).to.be.true
        expect(@board.wall_at(-17, 0)).to.be.true
        expect(@board.wall_at(0,-17)).to.be.true
        expect(@board.wall_at(0,0)).to.be.false

  describe 'empty', ->
    it 'should have no tiles', ->
      expect(_.size @board.tiles).to.eq 0
      expect(@board.count).to.eq 0

    it 'should have no unplaceable tiles', ->
      expect(@board.unplaceable.length).to.eq 0

    it 'should have no valid openings', ->
      openings = @board.find_valid_openings()
      expect(openings['start']).to.eql []
      expect(openings['first']).to.eql []
      expect(openings['second']).to.eql []
      expect(openings['third']).to.eql []
      expect(openings['fourth']).to.eql []
      expect(openings['fifth']).to.eql []
      expect(openings['sixth']).to.eql []
      expect(openings['seventh']).to.eql []
      expect(openings['eighth']).to.eql []
      expect(openings['ninth']).to.eql []

    it 'should place the start tile correctly', ->
      @board.add_start_tile()
      expect(_.size @board.tiles).to.eq 1
      expect(@board.tiles[0][0].zone).to.eq 'start'
      expect(@board.tiles[0][0].x).to.eq 0
      expect(@board.tiles[0][0].y).to.eq 0

  describe 'laying tiles', ->
    it 'should place all the tiles', (done) ->
      tiles = { 'first': { '4': 20 } }
      board = new Board @context, 60, tiles, ['first'], @interval
      board.add_start_tile()
      board.lay_tiles()
      wait = setInterval (->
        if !board.running
          clearInterval(wait)
          expect(_.size board.unplaceable).to.eq 0
          expect(board.count).to.eq 21
          done()
      ), 1
    it 'should fail to place 5 dead ends', (done)->
      tiles = { 'first': { '1': 5 } }
      board = new Board @context, 60, tiles, ['first'], @interval
      board.add_start_tile()
      board.lay_tiles()
      wait = setInterval (->
        if !board.running
          clearInterval(wait)
          expect(_.size board.unplaceable).to.eq 1
          expect(board.count).to.eq 5
          done()
      ), 1
    it 'should place a 1 when it is surrounded, but fits', (done) ->
      tiles = { 'first': {'1', 1} }
      board = new Board @context, 60, tiles, ['first'], @interval
      create_box(board)

      board.lay_tiles()
      wait = setInterval (->
        if !board.running
          clearInterval(wait)
          expect(_.size board.unplaceable).to.eq 0
          expect(board.count).to.eq 10
          expect(board.tile_at(-1,0)).to.not.be.false
          done()
      ), 1

    it 'replaces the orientations when unplaceable', (done) ->
      tiles = { 'first': { '3': 1 } }
      board = new Board @context, 60, tiles, ['first'], @interval
      create_box(board)
      board.lay_tiles()
      wait = setInterval (->
        if !board.running
          clearInterval(wait)
          expect(_.size board.unplaceable).to.eq 1
          expect(_.size board.unplaceable[0].orientations).to.eq 3
          expect(board.unplaceable[0].orientations).to.not.include board.unplaceable[0].orientation
          done()
      ), 1

    it 'places tiles in zone order', (done) ->
      tiles = { 'first': { '2-straight': 1 } , 'second': { '2-straight': 1 }, 'third': { '2-straight': 1 }, 'fourth': { '2-straight': 1 }, 'fifth': { '2-straight': 1 } }
      board = new Board @context, 60, tiles, ['first', 'second', 'third', 'fourth', 'fifth'], @interval
      close_all_but_east(board)
      board.lay_tiles()
      wait = setInterval (->
        if !board.running
          clearInterval(wait)
          expect(board.tile_at(1,0).zone).to.eq 'first'
          expect(board.tile_at(2,0).zone).to.eq 'second'
          expect(board.tile_at(3,0).zone).to.eq 'third'
          expect(board.tile_at(4,0).zone).to.eq 'fourth'
          expect(board.tile_at(5,0).zone).to.eq 'fifth'
          done()
      ), 1
    it 'should clear the placed count'
    it 'should list unplaceable tiles'
  describe 'processing tiles for layout', ->
    it 'should sort tiles in (reverse) order', ->
      tiles = { 'first': { '4': 2 }, 'second': { '4': 2 } }
      board = new Board @context, 60, tiles, ['first', 'second'], @interval
      tile_list = board.process_tiles_for_laying()
      expect(_.size tile_list).to.eq 4
      expect(tile_list.pop().zone).to.eq 'first'
      expect(tile_list.pop().zone).to.eq 'first'
      expect(tile_list.pop().zone).to.eq 'second'
      expect(tile_list.pop().zone).to.eq 'second'

  describe 'add_tile', ->
    it 'checks if the connections are valid', ->
      tiles = { 'first': { '1': 2 } }
      board = new Board @context, 60, tiles, ['first'], @interval
      board.add_start_tile()

      tile = new Tile 'first', '1', 60, board
      # east
      tile.rotate 3
      expect(board.add_tile(tile, 0, 1)).to.be.false

    it 'must be next to at least one tile', ->
      tiles = { 'first': { '1': 2 } }
      board = new Board @context, 60, tiles, ['first'], @interval
      board.add_start_tile()

      tile = new Tile 'first', '1', 60, board
      expect(board.add_tile(tile, 2, 2)).to.be.false

    it 'allows the start tile to have no neighbors', ->
      tiles = { 'first': { '1': 2 } }
      board = new Board @context, 60, tiles, ['first'], @interval
      expect(board.add_start_tile()).to.not.be.false

    it 'may not be where a tile exists', ->
      tiles = { 'first': { '1': 2 } }
      board = new Board @context, 60, tiles, ['first'], @interval
      board.add_start_tile()
      tile = new Tile 'first', '1', 60, board
      expect(board.add_tile(tile, 0, 0)).to.be.false

    it 'must have an x', ->
      tiles = { 'first': { '1': 2 } }
      board = new Board @context, 60, tiles, ['first'], @interval
      board.add_start_tile()

      tile = new Tile 'first', '1', 60, board
      expect(board.add_tile(tile, undefined, 1)).to.be.false

    it 'must have a y', ->
      tiles = { 'first': { '1': 2 } }
      board = new Board @context, 60, tiles, ['first'], @interval
      board.add_start_tile()

      tile = new Tile 'first', '1', 60, board
      expect(board.add_tile(tile, 1)).to.be.false
