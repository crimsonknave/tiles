expect = require('chai').expect
Board = require 'board'
_ = require 'underscore'
$ = require 'jquery'

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

  describe 'laying tiless', ->
    it 'should place all the tiles', (done) ->
      tiles = { '4': 20 }
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
      tiles = { '1': 5 }
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
    it 'should clear the placed count'
    it 'should list unplaceable tiles'
  describe 'processing tiles for layout', ->
    it 'should sort tiles in (reverse) order', ->
      tiles = { '4': 2 }
      board = new Board @context, 60, tiles, ['first', 'second'], @interval
      tile_list = board.process_tiles_for_laying()
      expect(_.size tile_list).to.eq 4
      expect(tile_list.pop().zone).to.eq 'first'
      expect(tile_list.pop().zone).to.eq 'first'
      expect(tile_list.pop().zone).to.eq 'second'
      expect(tile_list.pop().zone).to.eq 'second'

      


