_ = require 'underscore'
$ = require 'jquery'
fabric = require('fabric').fabric
module.exports = class Character
  constructor: (@board, @color)->
    @tile = @board.start_tile
    @moves = []
    @tile.characters.push this
    @size = @board.tile_size/6
    @board.characters.push this
    @player_number =_.size @board.characters

    @draw()


  move: (dir)->
    return false unless @tile[dir]
    new_tile = @tile.neighbor_to_the(dir)
    return false unless new_tile

    @moves.push dir
    @tile.characters.splice($.inArray(this, @tile.characters), 1)
    @tile = new_tile
    @tile.characters.push(this)
    @tile.explored = true
    @set_icon_coords()
    @redraw()
    @board.toggled_tile.set_selected_info() if @board.toggled_tile

  create_icon: ->
    @icon = new fabric.Circle { radius: @size, fill: @color}
    @set_icon_coords()

  set_icon_coords: ->
    offset = (7 * @size/10)
    player_offset = @tile.fimg.getBoundingRect().width/2
    switch @player_number
      when 1
        x_offset = offset
        y_offset = offset
      when 2
        x_offset = ( offset / 2 ) + player_offset
        y_offset = offset
      when 3
        x_offset = ( offset / 2 ) + player_offset
        y_offset = ( offset / 2 ) + player_offset
      when 4
        x_offset = offset
        y_offset = ( offset / 2 ) + player_offset
    @icon.left = @tile.left + x_offset
    @icon.top = @tile.top + y_offset

  draw: ->
    @create_icon() unless @icon
    @board.canvas.add(@icon)

  redraw: ->
    @board.canvas.remove(@icon)
    @board.canvas.add(@icon)
