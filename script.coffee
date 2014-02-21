$ = jQuery
lay_random_tiles = (tiles, board) ->
  tile_stack = []
  for color, types of tiles
    for type, num of types
      for i in [1..num] by 1
        tile_stack.push "#{color}#{type}"

  fisherYates(tile_stack)

  rotate_tile = (t)->
    switch t
      when 'blue2-straight'
        rand = Math.floor(Math.random()*2)+1
        east = rand == 1
        west = rand == 1
        north = rand == 2
        south = rand == 2
      when 'blue2-turn'
        rand = Math.floor(Math.random()*4)+1
        east = rand == 1 || rand == 4
        west = rand == 2 || rand == 3
        north = rand == 3 || rand == 4
        south = rand == 1 || rand == 2
      when 'blue3'
        rand = Math.floor(Math.random()*4)+1
        east = rand == 1 || rand == 2 || rand == 3
        west = rand == 1 || rand == 3 || rand == 4
        north = rand == 1 || rand == 2 || rand == 4
        south = rand == 2 || rand == 3 || rand == 4
      when 'blue4'
        rand = 1
        east = true
        west = true
        north = true
        south = true
    name = "#{t}-#{rand}.png"
    return [north, east, south, west, name]

  #for t in tile_stack
  insert_tile = (t, count=0) ->
    slots = board.find_valid_openings()
    # Need to rework this whole thing
    # Right now it's finding all edges that have an opening
    # But we want to find every tile that is on the edge and then 
    # see if we can fit the tile next to it in every combo
    selected_slot = slots[Math.floor(Math.random()*slots.length)]
    x = selected_slot[0]
    y = selected_slot[1]
    [north, east, south, west, name] = rotate_tile(t)

    north_tile = board.tile_at(x, y+1)
    east_tile = board.tile_at(x+1, y)
    south_tile = board.tile_at(x, y-1)
    west_tile = board.tile_at(x-1, y)
    fits = true
    if north_tile && (north_tile.south != north)
      fits = false
    if east_tile && (east_tile.west != east)
      fits = false
    if south_tile && (south_tile.north != south)
      fits = false
    if west_tile && (west_tile.east != west)
      fits = false

    if fits
      tile = new Tile name, x, y, north, east, south, west
      board.add_tile(tile)
    else
      if count < 10
        insert_tile(t, count+1)
      else
        console.log 'ran out of tries'

  timer = setInterval (->
    if tile_stack.length == 1
      console.log 'Placing the last tile'
      clearInterval(timer)
    insert_tile(tile_stack.pop())
  ), 100

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
    @img = new Image
    @img.setAtX=@x+@offset
    @img.setAtY=-1*@y+@offset
    @img.onload = ->
      context.drawImage(this,this.setAtX*121,this.setAtY*121, 121,121)
    @img.src = @image
    return this


class Board
  constructor: (@context)->
    @tiles = {}
    @count = 0
    @x = 5
    @y = 5

  add_start_tile: ->
    start_tile = new Tile 'start.png', 0, 0, true, true, true, true
    @add_tile(start_tile)

  add_tile: (tile)->
    return false if @tile_at tile.x, tile.y

    if @tiles[tile.x]
      obj = @tiles[tile.x]
      obj[tile.y] = tile
      
    else
      obj = {}
      obj[tile.y] = tile
      @tiles[tile.x] = obj
    @count += 1

    tile.draw(@context)

  wall_at: (x,y)->
    Math.abs(x) > @x || Math.abs(y) > @y

  tile_at: (x,y)->
    exists = false
    ys = @tiles[x]
    if ys
      exists = ys[y]
    return exists

  tile_count: ->
    @count

  find_valid_openings: ->
    openings = []
    for x, tiles of @tiles
      for y, tile of tiles
        if tile.north
          coords = [tile.x,tile.y+1]
          openings.push coords unless(@tile_at.apply(@, coords)|| @wall_at.apply(@, coords))
        if tile.east
          coords = [tile.x+1,tile.y]
          openings.push coords unless(@tile_at.apply(@, coords)|| @wall_at.apply(@, coords))
        if tile.south
          coords = [tile.x,tile.y-1]
          openings.push coords unless(@tile_at.apply(@, coords)|| @wall_at.apply(@, coords))
        if tile.west
          coords = [tile.x-1,tile.y]
          openings.push coords unless(@tile_at.apply(@, coords)|| @wall_at.apply(@, coords))
    return openings


$(document).ready ->
  canvas = document.getElementById('my_canvas')
  context = canvas.getContext('2d')
  tiles = {
    blue: {
      '4': 10,
      '3': 12,
      '2-straight': 15,
      '2-turn': 20
    }
  }
  board = new Board context
  board.add_start_tile()
  lay_random_tiles(tiles, board)
