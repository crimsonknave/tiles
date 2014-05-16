chai = require('chai')
sinon = require 'sinon'
sinon_chai = require 'sinon-chai'
expect = chai.expect
chai.use(sinon_chai)

Board = require 'board'
Character = require 'character'
fabric = require('fabric').fabric
_ = require 'underscore'
$ = require 'jquery'
describe 'Character', ->
  beforeEach ->
    document.body.innerHTML = __html__['index.html']
    canvas = new fabric.StaticCanvas('my_canvas')
    selected_zones = ['first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth']
    interval = 0
    @board = new Board canvas, 60, [], selected_zones, interval
    @board.add_start_tile()

  it 'a new character', ->
    character = new Character @board, 'black'
    expect(character.tile).to.equal(@board.start_tile)

  describe 'drawing', ->
    it 'uses fabric', ->
      character = new Character @board

