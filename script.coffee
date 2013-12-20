$ = jQuery
lay_random_tiles = (tiles) ->
  canvas = document.getElementById('my_canvas')
  context = canvas.getContext('2d')
  tile_stack = []
  for color, types of tiles
    for type, num of types
      for i in [1..num] by 1
        tile_stack.push "#{color}#{type}.png"

  fisherYates(tile_stack)

  x = 0
  y = 0
  for tile in tile_stack
    img = new Image
    img.setAtX=x
    img.setAtY=y
    img.onload = ->
      context.drawImage(this,this.setAtX*100,this.setAtY*100, 100,100)
    img.src = tile
    if x < 9
      x = x+1
    else
      x = 0
      y = y + 1

fisherYates = (arr) ->
  i = arr.length
  if i is 0 then return false

  while --i
    j = Math.floor(Math.random() * (i+1))
    [arr[i], arr[j]] = [arr[j], arr[i]] # use pattern matching to swap

$(document).ready ->
  tiles = {
    blue: {
      '4': 7,
      '3': 13,
      '2-straight': 20,
      '2-turn': 14
    }
  }
  lay_random_tiles(tiles)
