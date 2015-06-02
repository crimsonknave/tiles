Tile = require 'tile'
Character = require 'character'
$ = require 'jquery'
_ = require 'underscore'
fabric = require('fabric').fabric
module.exports = class Board
  constructor: (@canvas, @tile_size, @tile_list, @zones, @interval)->
    @left=2
    @right=2
    @top=2
    @bottom=2
    @tiles = {}
    @count = 0
    @last_was_placeable = true
    @unplaceable = []
    @characters = []
    if @tile_size == 60
      @x = 16
      @y = 16
    else
      @x = 8
      @y = 8

  add_character: (color)=>
    character = new Character(this, color)

  add_start_tile: ->
    @start_tile = new Tile 'start', '4', @tile_size, this
    @add_tile(@start_tile, 0, 0)

  redraw: ->
    for x, tiles of @tiles
      for y, tile of tiles
        tile.redraw()

  resize: ->
    @canvas.setWidth (@left + @right + 1 ) *@tile_size
    @canvas.setHeight (@top + @bottom + 1 ) *@tile_size
    @redraw()

  add_tile: (tile, x=false, y=false)->
    return false if x == false
    return false if y == false
    return false if @tile_at x, y
    if @tile_fits(tile, x,y)
      tile.x = x
      tile.y = y
    else
      return false

    @ensure_fits(x,y)

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

  ensure_fits: (x,y)->
    changed = false
    if x < -@left
      changed = true
      @left = -x
    else if x > @right
      changed = true
      @right = x
    if y > @top
      changed = true
      @top = y
    else if y < -@bottom
      changed = true
      @bottom = -y

    @resize() if changed


  tile_fits: (tile, x, y)->
    north_tile = @tile_at(x, y+1)
    east_tile = @tile_at(x+1, y)
    south_tile = @tile_at(x, y-1)
    west_tile = @tile_at(x-1, y)
    fits = true
    if north_tile && (north_tile.south != tile.north)
      fits = false
    if east_tile && (east_tile.west != tile.east)
      fits = false
    if south_tile && (south_tile.north != tile.south)
      fits = false
    if west_tile && (west_tile.east != tile.west)
      fits = false
    unless north_tile || east_tile || south_tile || west_tile || tile.zone == 'start'
      fits = false
    return fits

  wall_at: (x,y)->
    x < -@left || x > @right || y > @top || y < -@bottom


  tile_at_canvas_coords: (x,y)->
    board_x = Math.floor(x/@tile_size) - @left
    board_y = -1 * (Math.floor(y/@tile_size) - @top)
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
          openings[tile.zone].push coords unless @tile_at.apply(@, coords)
        if tile.east
          coords = [tile.x+1,tile.y]
          openings[tile.zone].push coords unless @tile_at.apply(@, coords)
        if tile.south
          coords = [tile.x,tile.y-1]
          openings[tile.zone].push coords unless @tile_at.apply(@, coords)
        if tile.west
          coords = [tile.x-1,tile.y]
          openings[tile.zone].push coords unless @tile_at.apply(@, coords)
    return openings

  wall_warning: (char, dir)->
    console.log 'failed to move!'
    switch dir
      when 'north'
        console.log 'north'
        #x1 = char.tile.left - (@tile_size/2) - 3
        x1 = char.tile.left - 3
        y1 = char.tile.top
        x2 = x1 + @tile_size
        y2 = y1
      when 'east'
        console.log 'east'
        x1 = char.tile.left + @tile_size - 7
        y1 = char.tile.top - 3
        x2 = x1
        y2 = y1 + @tile_size
      when 'south'
        console.log 'south'
        x1 = char.tile.left - 3
        y1 = char.tile.top - 7 + @tile_size
        x2 = x1 + @tile_size
        y2 = y1
      when 'west'
        console.log 'west'
        x1 = char.tile.left
        y1 = char.tile.top - 3
        x2 = x1
        y2 = y1 + @tile_size

    line = new fabric.Line([x1, y1, x2, y2], {
      strokeWidth: @tile_size/10,
      stroke: 'red',
      opacity: 0.75
    })
    console.log char.tile
    console.log line
    @canvas.add(line)
    line.animate('opacity', 0,
      onChange: @canvas.renderAll.bind(@canvas),
      duration: 1000)

  move_character: (number, dir)->
    char = @characters[number]
    success = char.move dir
    unless success
      @wall_warning char, dir

  call_when_ready: (func, params)->
    running = setInterval (=>
      unless @running
        func.apply(this, params)
        clearInterval(running)
    ), 10

  process_tiles_for_laying: ->
    @stop_placing = false
    @running = true
    tile_stack = []
    @unplaceable = []
    @last_was_placeable = true
    for zone in @zones.reverse()
      stack = []
      for type, num of @tile_list[zone]
        for i in [1..num] by 1
          tile = new Tile zone, type, @tile_size, this
          stack.push tile
      stack = _.shuffle(stack)
      tile_stack = tile_stack.concat stack

    $('span.max').text tile_stack.length
    $('span.min').removeClass('green')
    $('span.min').removeClass('red')
    return tile_stack

  sort_openings: (tile) ->
    openings = @find_valid_openings()
    other_zones = []

    matching_slots = openings[tile.zone]
    delete openings[tile.zone]
    _.each _.values(openings), (value)->
      other_zones = other_zones.concat value

    matching_slots = _.shuffle(matching_slots)
    other_zones = _.shuffle(other_zones)
    return matching_slots.concat other_zones
  place_tile: (tile) ->
    all_slots = @sort_openings(tile)
    i = 0
    for slot in all_slots
      loop
        if @add_tile(tile, slot[0], slot[1])
          @last_was_placeable = true
          return true
        break if tile.orientations.length == 0
        tile.rotate tile.orientations.pop()
    @unplaceable.push tile
    tile.set_orientations()
    @last_was_placeable = false
    return false


  lay_tiles: ->
    $('#my_canvas').removeClass('hidden')
    @canvas.setWidth (@left + @right + 1 ) *@tile_size
    @canvas.setHeight (@top + @bottom + 1 ) *@tile_size

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
        success = @place_tile next_tile
        $('span.min').text @count - 1 if success
    ), @interval
