Tile = require './tile'
$ = require './jquery-1.10.2'
fisherYates = require './fisher'
module.exports = class Board
  constructor: (@context, @size, @tile_list, @colors, @interval)->
    @tiles = {}
    @count = 0
    @last_was_placeable = true
    @unplaceable = []
    if @size == 60
      @x = 16
      @y = 16
    else
      @x = 8
      @y = 8

  add_start_tile: ->
    start_tile = new Tile 'start', '4', @size, this
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

  lay_tiles: ->
    @stop_placing = false
    @running = true
    tile_stack = []
    @unplaceable = []
    @last_was_placeable = true
    for color in @colors.reverse()
      stack = []
      for type, num of @tile_list
        for i in [1..num] by 1
          tile = new Tile color, type, @size, this
          stack.push tile
      fisherYates(stack)
      tile_stack = tile_stack.concat stack

    $('span.max').text tile_stack.length
    $('span.min').removeClass('green')
    $('span.min').removeClass('red')
    timer = setInterval (=>
      if @stop_placing
        console.log 'Stopping as requested'
        clearInterval(timer)
        @running = false
        return false
      if tile_stack.length == 0 && (!@last_was_placeable || @unplaceable.length == 0 )
        console.log 'Placed the last tile'
        console.log tile_stack
        console.log @unplaceable
        if @unplaceable.length > 0
          $('span.min').addClass('red')
        else
          $('span.min').addClass('green')

        console.log "Placed #{@count} tiles"
        clearInterval(timer)
        @running = false
      if @unplaceable.length > 0 && @last_was_placeable
        next_tile = @unplaceable.pop()
      else
        next_tile = tile_stack.pop()
      if next_tile
        next_tile.place() 
        $('span.min').text @count - 1
    ), @interval
