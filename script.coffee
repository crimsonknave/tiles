$ = jQuery
lay_random_tiles = (colors, tiles, board, interval) ->
  console.log 'laying tiles'
  @stop = false
  @running = true
  tile_stack = []
  unplaceable = []
  last_was_placeable = true
  for color in colors.reverse()
    stack = []
    for type, num of tiles
      for i in [1..num] by 1
        stack.push [color, type]
    fisherYates(stack)
    tile_stack = tile_stack.concat stack

  rotations_for_tile = (t)->
    rotations = {
      '1': 4,
      '2-straight': 2,
      '2-turn': 4,
      '3': 4,
      '4': 1
    }
    return rotations[t]

  rotate_tile = (t, color, orientation)->
    switch t
      when '1'
        east = orientation == 3
        west = orientation == 1
        north = orientation == 2
        south = orientation == 4
      when '2-straight'
        east = orientation == 1
        west = orientation == 1
        north = orientation == 2
        south = orientation == 2
      when '2-turn'
        east = orientation == 1 || orientation == 4
        west = orientation == 2 || orientation == 3
        north = orientation == 3 || orientation == 4
        south = orientation == 1 || orientation == 2
      when '3'
        east = orientation == 1 || orientation == 2 || orientation == 3
        west = orientation == 1 || orientation == 3 || orientation == 4
        north = orientation == 1 || orientation == 2 || orientation == 4
        south = orientation == 2 || orientation == 3 || orientation == 4
      when '4'
        east = true
        west = true
        north = true
        south = true
    name = "#{color}#{t}-#{orientation}.png"
    return [north, east, south, west, name]

  # We iterate over all the slots
  # For each slot we try a random rotation and see if the tile fits
  # If not we try all the other orientations in order
  # If none of those fit we move on to the next random slot
  # If none of the slots fit we place the tile in unplaceable and 
  # note that we could not place a tile
  # We will try and place the tiles in unplaceable once we've places a new
  # tile
  insert_tile = (color, t) ->
    slots = board.find_valid_openings()
    fisherYates(slots)
    i = 0
    for slot in slots
      max = rotations_for_tile(t)
      orientations = [1..max]
      fisherYates(orientations)
      for orientation in orientations
        i++
        x = slot[0]
        y = slot[1]
        [north, east, south, west, name] = rotate_tile(t, color, orientation)

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
          tile = new Tile "images/#{name}", x, y, north, east, south, west, board.size
          board.add_tile(tile)
          last_was_placeable = true
          return true
    unplaceable.push [color, t]
    last_was_placeable = false
    return false

  timer = setInterval (->
    if @stop
      console.log 'Stopping as requested'
      clearInterval(timer)
      @running = false
      return false
    if tile_stack.length == 0 && (!last_was_placeable || unplaceable.length == 0 )
      console.log 'Placed the last tile'
      console.log tile_stack
      console.log unplaceable
      console.log "Placed #{board.count} tiles"
      clearInterval(timer)
      @running = false
      console.log 'after'
    if unplaceable.length > 0 && last_was_placeable
      next_tile = unplaceable.pop()
    else
      next_tile = tile_stack.pop()
    insert_tile.apply(@,next_tile)
  ), interval

fisherYates = (arr) ->
  i = arr.length
  if i is 0 then return false

  while --i
    j = Math.floor(Math.random() * (i+1))
    [arr[i], arr[j]] = [arr[j], arr[i]] # use pattern matching to swap

class Tile
  constructor: (@image, @x, @y, @north, @east, @south, @west, @size) ->
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
    @img.src = @image
    return this


class Board
  constructor: (@context, @size)->
    @tiles = {}
    @count = 0
    if @size == 60
      @x = 16
      @y = 16
    else
      @x = 8
      @y = 8

  add_start_tile: ->
    start_tile = new Tile 'images/start.png', 0, 0, true, true, true, true, @size
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
  $('.save').click ->
    canvas = document.getElementById('my_canvas')
    image = canvas.toDataURL('map.png').replace('image/png', 'image/octet-stream')
    window.location.href = image
  $('.submit').click ->
    size = parseInt($('.size').val())
    interval = parseInt($('.interval').val())
    tiles = {
      '4': parseInt($('.4').val()) || 0,
      '3': parseInt($('.3').val()) || 0,
      '2-straight': parseInt($('.2-straight').val()) || 0,
      '2-turn': parseInt($('.2-turn').val()) || 0,
      '1': parseInt($('.1').val()) || 0
    }
    build_map(tiles, size, interval)

build_map = (tiles, size, interval)->
  canvas = document.getElementById('my_canvas')
  context = canvas.getContext('2d')

  @stop = true
  stopping = setInterval (->
    if @running
      console.log 'waiting for the previous draw to stop'
    else
      console.log 'starting to draw'
      context.clearRect( 0, 0, 2057, 2057)
      colors = ['green', 'yellow', 'red']
      board = new Board context, size
      board.add_start_tile()
      lay_random_tiles(colors, tiles, board, interval)
      clearInterval(stopping)
  ), 10
