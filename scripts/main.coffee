$ = require('jquery')
_ = require('underscore')
Board = require('board')
fabric = require('fabric').fabric
board = false

$(document).ready ->
  $(document).keydown (e)->
    active_char = $('.character.active')[0]
    switch e.which
      when 37
        return unless active_char
        board.move_character(active_char.value, 'west')
        e.preventDefault()
      when 38
        return unless active_char
        board.move_character(active_char.value, 'north')
        e.preventDefault()
      when 39
        return unless active_char
        board.move_character(active_char.value, 'east')
        e.preventDefault()
      when 40
        return unless active_char
        board.move_character(active_char.value, 'south')
        e.preventDefault()
      when 9
        next_character()
        e.preventDefault()

  $('.character').click ->
    $('.character').removeClass('active')
    $(this).addClass('active')
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

next_character = ->
  char = $('.character.active')[0]
  char = $('.character.fourth')[0] unless char
  $('.character').removeClass('active')
  next = {
    0: {label: '.second', color: 'rgba(0,0,0,0.25)'},
    1: {label: '.third', color: 'rgba(255,0,0,0.25)'},
    2: {label: '.fourth', color: 'rgba(128,0,128,0.25)'},
    3: {label: '.first', color: 'rgba(0,128,0,0.25'}
  }
  next_char = next[char.value]
  $(".character#{next_char.label}").addClass('active')
  $('.character_info')[0].style.backgroundColor = next_char.color

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
        zone_numbers = get_zone_numbers()

        tile_list = {}
        for zone in selected_zones
          tile_list[zone] = { '4': 0, '3': 0, '2-straight': 0, '2-turn': 0, '1': 0 }
          bag = []
          for tile, number of zone_numbers[zone]
            _(number).times ->
              bag.push(tile)
          bag = _.shuffle(bag)
          _(6).times ->
            tile = bag.pop()
            tile_list[zone][tile] += 1
      else
        tile_list = {}
        for zone in selected_zones
          tile_list[zone] = tiles
      window.board = board = new Board canvas, size, tile_list, selected_zones, interval
      board.add_start_tile()
      board.lay_tiles()
      board.call_when_ready(board.add_character, ['green'])
      board.call_when_ready(board.add_character, ['black'])
      board.call_when_ready(board.add_character, ['red'])
      board.call_when_ready(board.add_character, ['purple'])
      clearInterval(stopping)
  ), 10
