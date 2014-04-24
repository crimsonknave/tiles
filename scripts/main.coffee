$ = require('jquery')
fisherYates = require('fisher')
Board = require('board')
fabric = require('fabric').fabric
board = false

$(document).ready ->
  $('.toggle').click ->
    $('.toggle').toggleClass('hidden')
    $('.config').toggleClass('collapsed')

  # FIXME: Probably can do this easier with fabric
  $('#my_canvas').mousedown (e)->
    return unless board
    canvas_x = e.pageX - $(this).offset().left
    canvas_y = e.pageY - $(this).offset().top
    tile = board.tile_at_canvas_coords(canvas_x, canvas_y)
    if tile
      tile.toggle()

  $('.save').click ->
    canvas = document.getElementById('my_canvas')
    image = canvas.toDataURL('map.png').replace('image/png', 'image/octet-stream')
    lnk = document.createElement('a') unless @lnk
    lnk.download = 'map.png'
    lnk.href = image
    lnk.click()


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
  canvas = new fabric.StaticCanvas('my_canvas')

  if board
    board.stop_placing = true
  stopping = setInterval (->
    if board && board.running
    else
      number_of_zones = $('select.zones').val()
      zones = ['first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth']
      selected_zones = zones.slice(0,number_of_zones)
      board = new Board canvas, size, tiles, selected_zones, interval
      board.add_start_tile()
      board.lay_tiles()
      clearInterval(stopping)
  ), 10
