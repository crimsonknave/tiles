fisherYates = require('./fisher')
module.exports = class Tile
  constructor: (@color, @type, @size, @board) ->
    if @color == 'start'
      @name = 'images/start.png'
      @x = 0
      @y = 0
      @set_exits()
    else
      # Get a list of random orientations and pop the first
      @orientations = @rotations()
      fisherYates(@orientations)
      @rotate @orientations.pop()

    if @size == 121
      @offset = 8
    else
      @offset = 16

  draw: (context) ->
    @img = new Image
    @img.setAtX=@x+@offset
    @img.setAtY=-1*@y+@offset
    @img.onload = =>
      context.drawImage(@img,@img.setAtX*@size,@img.setAtY*@size, @size,@size)
    @img.src = @name
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
    @name = "images/#{@color}#{@type}-#{@orientation}.png"
    @set_exits()

  # We iterate over all the slots
  # For each slot we try a random rotation and see if the tile fits
  # If not we try all the other orientations in order
  # If none of those fit we move on to the next random slot
  # If none of the slots fit we place the tile in unplaceable and 
  # note that we could not place a tile
  # We will try and place the tiles in unplaceable once we've places a new
  # tile
  place: ->
    slots = @board.find_valid_openings()
    fisherYates(slots)
    i = 0
    for slot in slots
      loop
        x = slot[0]
        y = slot[1]

        north_tile = @board.tile_at(x, y+1)
        east_tile = @board.tile_at(x+1, y)
        south_tile = @board.tile_at(x, y-1)
        west_tile = @board.tile_at(x-1, y)
        fits = true
        if north_tile && (north_tile.south != @north)
          fits = false
        if east_tile && (east_tile.west != @east)
          fits = false
        if south_tile && (south_tile.north != @south)
          fits = false
        if west_tile && (west_tile.east != @west)
          fits = false

        if fits
          @x = x
          @y = y
          @board.add_tile(this)
          @board.last_was_placeable = true
          return true
        break if @orientations.length == 0
        @rotate @orientations.pop()
    @board.unplaceable.push this
    @board.last_was_placeable = false
    return false
