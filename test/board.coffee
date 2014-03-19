expect = require('chai').expect
Board = require 'board'
_ = require 'underscore-min'
$ = require 'jquery-1.10.2'

describe 'Board', ->
  before ->
    document.body.innerHTML = __html__['index.html']
    canvas = document.getElementById('my_canvas')
    context = canvas.getContext('2d')
    selected_zones = ['first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth']
    interval = 0
    @board = new Board context, 60, [], selected_zones, interval

  describe 'empty', ->
    it 'should have no tiles', ->
      expect(_.size @board.tiles).to.be.eq 0

