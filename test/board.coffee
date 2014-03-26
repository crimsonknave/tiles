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


