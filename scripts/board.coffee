Tile = require 'tile'
Character = require 'character'
$ = require 'jquery'
_ = require 'underscore'
fisherYates = require 'fisher'
module.exports = class Board
  constructor: (@canvas, @size, @tile_list, @zones, @interval)->
    @tiles = {}
    @count = 0
    @last_was_placeable = true
    @unplaceable = []
    @characters = []
    if @size == 60
      @x = 16
      @y = 16
    else
      @x = 8
      @y = 8

  add_character: (color)=>
    console.log "adding chara with color: #{color}"
    character = new Character(this, color)

  add_start_tile: ->
    @start_tile = new Tile 'start', '4', @size, this
    @add_tile(@start_tile)

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

    tile.draw()
    tile.placement_id = @count - 1

  wall_at: (x,y)->
    Math.abs(x) > @x || Math.abs(y) > @y

  tile_at_canvas_coords: (x,y)->
    board_x = Math.floor(x/@size) - @x
    board_y = -1 * (Math.floor(y/@size) - @y)
    @tile_at(board_x, board_y)

  tile_at: (x,y)->
    exists = false
    ys = @tiles[x]
    if ys
      exists = ys[y]
    return exists || false

  find_valid_openings: ->
    openings = {
    'start': [],
    'first': [],
    'second': [],
    'third': [],
    'fourth': [],
    'fifth': [],
    'sixth': [],
    'seventh': [],
    'eighth': [],
    'ninth': []
    }
    for x, tiles of @tiles
      for y, tile of tiles
        if tile.north
          coords = [tile.x,tile.y+1]
          openings[tile.zone].push coords unless(@tile_at.apply(@, coords)|| @wall_at.apply(@, coords))
        if tile.east
          coords = [tile.x+1,tile.y]
          openings[tile.zone].push coords unless(@tile_at.apply(@, coords)|| @wall_at.apply(@, coords))
        if tile.south
          coords = [tile.x,tile.y-1]
          openings[tile.zone].push coords unless(@tile_at.apply(@, coords)|| @wall_at.apply(@, coords))
        if tile.west
          coords = [tile.x-1,tile.y]
          openings[tile.zone].push coords unless(@tile_at.apply(@, coords)|| @wall_at.apply(@, coords))
    return openings

  move_character: (number, dir)->
    @characters[number].move dir

  call_when_ready: (func, params)->
    running = setInterval (=>
      unless @running
        func.apply(this, params)
        clearInterval(running)
    ), 10

  process_tiles_for_laying: ->
    console.log 'processing'
    @stop_placing = false
    @running = true
    tile_stack = []
    @unplaceable = []
    @last_was_placeable = true
    for zone in @zones.reverse()
      stack = []
      for type, num of @tile_list[zone]
        for i in [1..num] by 1
          tile = new Tile zone, type, @size, this
          stack.push tile
      fisherYates(stack)
      tile_stack = tile_stack.concat stack

    $('span.max').text tile_stack.length
    $('span.min').removeClass('green')
    $('span.min').removeClass('red')
    return tile_stack

  lay_tiles: ->
    tile_stack = @process_tiles_for_laying()
    timer = setInterval (=>
      if @stop_placing
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
