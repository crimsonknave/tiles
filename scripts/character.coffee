_ = require 'underscore'
$ = require 'jquery'
fabric = require('fabric').fabric
module.exports = class Character
  constructor: (@board, @color)->
    console.log 'creating a character'
    @tile = @board.start_tile
    @tile.characters.push this
    @size = @board.size/6
    @board.characters.push this
    @player_number =_.size @board.characters
    console.log "color: #{@color}"

    @draw()


  move: (dir)->
    console.log "moving #{dir}"
    new_tile = @tile.neighbor_to_the(dir)
    return false unless new_tile
    @tile.characters.splice($.inArray(this, @tile.characters), 1)
    @tile = new_tile
    @tile.characters.push(this)
    @set_icon_coords()
    @redraw()

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
    @icon.left = @tile.fimg.left + x_offset
    @icon.top = @tile.fimg.top + y_offset
    console.log @icon.left
    console.log @icon.top

  draw: ->
    @create_icon() unless @icon
    @board.canvas.add(@icon)

  redraw: ->
    @board.canvas.remove(@icon)
    @board.canvas.add(@icon)
