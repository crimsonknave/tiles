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

$(document).ready ->
  $('.save').click ->
    canvas = document.getElementById('my_canvas')
    image = canvas.toDataURL('map.png').replace('image/png', 'image/octet-stream')
    @lnk = document.createElement('a') unless @lnk
    @lnk.download = 'map.png'
    @lnk.href = image
    @lnk.click()


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
