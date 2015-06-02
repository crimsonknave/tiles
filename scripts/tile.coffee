$ = require 'jquery'
_ = require 'underscore'
fabric = require('fabric').fabric
module.exports = class Tile
  constructor: (@zone, @type, @size, @board, @id = false) ->
    @characters = []
    if @zone == 'start'
      @file = 'images/start.png'
      @x = 0
      @y = 0
      @set_exits()
    else
      @set_orientations()

    if @size == 121
      @offset = 8
    else
      @offset = 16

  set_orientations: ->
    @orientations = _.shuffle(@rotations())
    @rotate @orientations.pop()

  character_list: ->
    _.map(@characters, (char)->
      char.color
    )

  neighbor_to_the: (dir)->
    switch dir
      when 'north'
        x = @x
        y = @y + 1
      when 'east'
        x = @x + 1
        y = @y
      when 'south'
        x = @x
        y = @y - 1
      when 'west'
        x = @x - 1
        y = @y
    return @board.tile_at(x,y)
    
  empty_exits: ->
    exits = []
    exits.push ['N'] if @north && !@neighbor_to_the('north')
    exits.push ['E'] if @east && !@neighbor_to_the('east')
    exits.push ['S'] if @south && !@neighbor_to_the('south')
    exits.push ['W'] if @west && !@neighbor_to_the('west')
    return exits.join ', '

  exit_list: ->
    exits = []
    exits.push ['N'] if @north
    exits.push ['E'] if @east
    exits.push ['S'] if @south
    exits.push ['W'] if @west
    return exits.join ', '

  untoggle: ->
    @toggled = false
    @fimg.opacity = 1
    @redraw()

  toggle: ->
    @toggled = !@toggled
    if @board.toggled_tile && @board.toggled_tile != this
      @board.toggled_tile.untoggle()
    @board.toggled_tile = this
    @fimg.opacity = if @toggled then 0.5 else 1
    @redraw()
    $.get('templates/info.html', (data)=>
      html = _.template(data, this)
      info = $('.info')
      info.html(html)
      info.removeClass('hidden')
    , 'html')

  create_image: ->
    @img = new Image
    @img.setAtX=@x+@offset
    @img.setAtY=-1*@y+@offset
    @fimg = new fabric.Image(@img, {
      left: @img.setAtX*@size,
      top: @img.setAtY*@size,
      width: @size,
      height: @size
    })
    #@fimg.mousedown ->
      #@toggle()

  redraw: ->
    @board.canvas.remove(@fimg)
    @board.canvas.add(@fimg)
    _.map(@characters, (char)->
      char.redraw()
    )

  draw: ->
    @create_image() unless (@img && @fimg)
    @img.onload = =>
      @board.canvas.add(@fimg)
    @img.src = @file
    return this

  rotations: ->
    switch @type
      when '1'
        return [1..4]
      when '2-straight'
        return [1,2]
      when '2-turn'
        return [1..4]
      when '3'
        return [1..4]
      when '4'
        return [1]

  set_exits: ->
    switch @type
      when '1'
        @east = @orientation == 3
        @west = @orientation == 1
        @north = @orientation == 2
        @south = @orientation == 4
      when '2-straight'
        @east = @orientation == 1
        @west = @orientation == 1
        @north = @orientation == 2
        @south = @orientation == 2
      when '2-turn'
        @east = @orientation == 1 || @orientation == 4
        @west = @orientation == 2 || @orientation == 3
        @north = @orientation == 3 || @orientation == 4
        @south = @orientation == 1 || @orientation == 2
      when '3'
        @east = @orientation == 1 || @orientation == 2 || @orientation == 3
        @west = @orientation == 1 || @orientation == 3 || @orientation == 4
        @north = @orientation == 1 || @orientation == 2 || @orientation == 4
        @south = @orientation == 2 || @orientation == 3 || @orientation == 4
      when '4'
        @east = true
        @west = true
        @north = true
        @south = true

  rotate: (orientation) ->
    @orientation = orientation
    @file = "images/#{@zone}#{@type}-#{@orientation}.png"
    @set_exits()
