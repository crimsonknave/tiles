$ = require('jquery')
_ = require('underscore')
fisherYates = require('fisher')
Board = require('board')
fabric = require('fabric').fabric
board = false

$(document).ready ->
  $('.toggle').click ->
    $('.toggle').toggleClass('hidden')
    $('.config').toggleClass('collapsed')

  $('.bag').click (e)->
    $('.non-bag').toggleClass('hidden')
    box = $('.bag input')[0]
    unless e.target.type == 'checkbox'
      box.checked = !box.checked

  # FIXME: Probably can do this easier with fabric
  # Note: Yes, but at the cost of speed, *all* the interactions
  # which means fighting to turn most of them off and so on
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

get_zone_numbers = ->
  json = null
  $.ajax(
    async: false,
    global: false,
    url: 'zone_numbers.json',
    dataType: 'json',
    success: (data)->
      json = data
  )
  return json

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
      if $('.bag input')[0].checked
        console.log 'pulling from bag'
        zone_numbers = get_zone_numbers()

        tile_list = {}
        for zone in selected_zones
          console.log "parsing #{zone}"
          tile_list[zone] = { '4': 0, '3': 0, '2-straight': 0, '2-turn': 0, '1': 0 }
          bag = []
          for tile, number of zone_numbers[zone]
            _(number).times ->
              bag.push(tile)
          console.log bag
          fisherYates(bag)
          _(6).times ->
            tile = bag.pop()
            tile_list[zone][tile] += 1
        console.log tile_list
      else
        console.log 'static tile numbers'
        tile_list = {}
        for zone in selected_zones
          tile_list[zone] = tiles
      board = new Board canvas, size, tile_list, selected_zones, interval
      board.add_start_tile()
      board.lay_tiles()
      clearInterval(stopping)
  ), 10
