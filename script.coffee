$ = jQuery
lay_random_tiles = (colors, tiles, board) ->
  tile_stack = []
  unplaceable = []
  for color in colors.reverse()
    stack = []
    for type, num of tiles
      for i in [1..num] by 1
        stack.push [color, type]
    fisherYates(stack)
    tile_stack = tile_stack.concat stack
  console.log tile_stack

  rotate_tile = (t, color)->
    switch t
      when '2-straight'
        rand = Math.floor(Math.random()*2)+1
        east = rand == 1
        west = rand == 1
        north = rand == 2
        south = rand == 2
      when '2-turn'
        rand = Math.floor(Math.random()*4)+1
        east = rand == 1 || rand == 4
        west = rand == 2 || rand == 3
        north = rand == 3 || rand == 4
        south = rand == 1 || rand == 2
      when '3'
        rand = Math.floor(Math.random()*4)+1
        east = rand == 1 || rand == 2 || rand == 3
        west = rand == 1 || rand == 3 || rand == 4
        north = rand == 1 || rand == 2 || rand == 4
        south = rand == 2 || rand == 3 || rand == 4
      when '4'
        rand = 1
        east = true
        west = true
        north = true
        south = true
    name = "#{color}#{t}-#{rand}.png"
    return [north, east, south, west, name]

  insert_tile = (color, t, count=0) ->
    slots = board.find_valid_openings()
    # Need to rework this whole thing
    # Right now it's finding all edges that have an opening
    # But we want to find every tile that is on the edge and then 
    # see if we can fit the tile next to it in every combo
    selected_slot = slots[Math.floor(Math.random()*slots.length)]
    x = selected_slot[0]
    y = selected_slot[1]
    [north, east, south, west, name] = rotate_tile(t, color)

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
      tile = new Tile "images/#{name}", x, y, north, east, south, west
      board.add_tile(tile)
    else
      if count < 10
        insert_tile(color, t, count+1)
      else
        console.log 'ran out of tries'

  timer = setInterval (->
    if tile_stack.length <= 1
      console.log 'Placing the last tile'
      clearInterval(timer)
    insert_tile.apply(@,tile_stack.pop())
  ), 100

fisherYates = (arr) ->
  i = arr.length
  if i is 0 then return false

  while --i
    j = Math.floor(Math.random() * (i+1))
    [arr[i], arr[j]] = [arr[j], arr[i]] # use pattern matching to swap

class Tile
  constructor: (@image, @x, @y, @north, @east, @south, @west) ->
    @offset = 8

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
    @x = 8
    @y = 8

  add_start_tile: ->
    start_tile = new Tile 'images/start.png', 0, 0, true, true, true, true
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
  $('.submit').click ->
    tiles = {
      '4': parseInt($('.4').val()) || 0
      '3': parseInt($('.3').val()) || 0
      '2-straight': parseInt($('.2-straight').val()) || 0
      '2-turn': parseInt($('.2-turn').val()) || 0
    }
    console.log tiles
    build_map(tiles)

build_map = (tiles)->
  canvas = document.getElementById('my_canvas')
  context = canvas.getContext('2d')
  context.clearRect( 0, 0, 2057, 2057)
  colors = ['green', 'yellow', 'red']
  board = new Board context
  board.add_start_tile()
  lay_random_tiles(colors, tiles, board)
