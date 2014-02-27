$ = require('./jquery-1.10.2')
fisherYates = require('./fisher')
Board = require('./board')


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

  if @board
    @board.stop_placing = true
  stopping = setInterval (->
    if @board && @board.running
    else
      context.clearRect( 0, 0, 2057, 2057)
      colors = ['first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth']
      @board = new Board context, size, tiles, colors, interval
      @board.add_start_tile()
      @board.lay_tiles()
      clearInterval(stopping)
  ), 10
