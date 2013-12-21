$ = jQuery
lay_random_tiles = (tiles, board) ->
  tile_stack = []
  for color, types of tiles
    for type, num of types
      for i in [1..num] by 1
        tile_stack.push "#{color}#{type}.png"

  fisherYates(tile_stack)

  for t in tile_stack
    slots = board.find_valid_openings()
    # Need to rework this whole thing
    # Right now it's finding all edges that have an opening
    # But we want to find every tile that is on the edge and then 
    # see if we can fit the tile next to it in every combo
    selected_slot = slots[Math.floor(Math.random()*slots.length)]
    x = selected_slot[0]
    y= selected_slot[1]
    switch t
      when 'blue2-straight.png'
        east = true
        west = true
        north = false
        south = false
      when 'blue2-turn.png'
        east = true
        west = false
        north = true
        south = false
      when 'blue3.png'
        east = true
        west = true
        north = true
        south = false
      when 'blue4.png'
        east = true
        west = true
        north = true
        south = true

    tile = new Tile t, x, y, north, east, south, west
    board.add_tile(tile)

fisherYates = (arr) ->
  i = arr.length
  if i is 0 then return false

  while --i
    j = Math.floor(Math.random() * (i+1))
    [arr[i], arr[j]] = [arr[j], arr[i]] # use pattern matching to swap

class Tile
  constructor: (@image, @x, @y, @north, @east, @south, @west) ->
    @offset = 7

  draw: (context) ->
    console.log "drawing #{@image}, at #{@x}x#{@y}"
    @img = new Image
    @img.setAtX=@x+@offset
    @img.setAtY=-1*@y+@offset
    @img.onload = ->
      context.drawImage(this,this.setAtX*100,this.setAtY*100, 100,100)
    @img.src = @image
    return this


class Board
  constructor: (@context)->
    @tiles = []

  add_start_tile: ->
    start_tile = new Tile 'start.png', 0, 0, true, true, true, true
    start_tile.draw(@context)
    @tiles.push start_tile

  add_tile: (tile)->
    if tile.draw(@context)
      @tiles.push tile

  tile_at: (x,y)->
    exists = false
    tile = @tiles[0]
    for tile in @tiles
      exists = true if tile.x == x and tile.y == y
    return exists

  tile_count: ->
    @tiles.length

  find_valid_openings: ->
    openings = []
    for tile in @tiles
      if tile.north
        coords = [tile.x,tile.y+1]
        openings.push coords unless @tile_at.apply @, coords
      if tile.east
        coords = [tile.x+1,tile.y]
        openings.push coords unless @tile_at.apply @, coords
      if tile.south
        coords = [tile.x,tile.y-1]
        openings.push coords unless @tile_at.apply @, coords
      if tile.west
        coords = [tile.x-1,tile.y]
        openings.push coords unless @tile_at.apply @, coords
    return openings


$(document).ready ->
  canvas = document.getElementById('my_canvas')
  context = canvas.getContext('2d')
  tiles = {
    blue: {
      #'3': 4
      '4': 7,
      '3': 13,
      '2-straight': 20,
      '2-turn': 14
    }
  }
  board = new Board context
  board.add_start_tile()
  lay_random_tiles(tiles, board)
  console.log board
  console.log board.tile_count()
