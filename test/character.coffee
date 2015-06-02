chai = require('chai')
sinon = require 'sinon'
sinon_chai = require 'sinon-chai'
expect = chai.expect
chai.use(sinon_chai)

Board = require 'board'
Character = require 'character'
Tile = require 'tile'
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
    expect(character.player_number).to.equal(1)

  describe 'drawing', ->
    it 'uses fabric'

  describe 'movement', ->
    beforeEach ->
      @character = new Character @board, 'black'
      tile = new Tile 'first', '1', @board.size, @board
      tile.rotate(4)
      @board.add_tile(tile, 0, 1)

      tile = new Tile 'first', '4', @board.size, @board
      @board.add_tile(tile, -1, 0)

      tile = new Tile 'first', '2-straight', @board.size, @board
      tile.rotate(2)
      @board.add_tile(tile, 0, 1)

    it 'fails when there is no tile there', ->
      expect(@character.move('south')).to.be.false

    it 'fails when there is no exit there', ->
      expect(@character.move('north')).to.not.be.false
      expect(@character.move('west')).to.be.false

    it 'succeedes', ->
      expect(@character.move('north')).to.not.be.false

    it 'marks the tile as explored', ->
      tile = @board.tile_at(0,1)
      expect(tile.explored).to.be.false
      @character.move('north')
      expect(@character.tile.explored).to.be.true

    it 'stores moves', ->
      expect(@character.moves.length).to.eq(0)
      @character.move('north')
      expect(@character.moves.length).to.eq(1)
    
    it 'updates the selected info', ->
      tile = @board.tile_at(0,0)
      tile.toggle()
      sinon.spy(tile, 'set_selected_info')
      @character.move('north')
      expect(tile.set_selected_info).to.have.been.calledOnce
