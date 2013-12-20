$ = jQuery
$(document).ready ->
  console.log 'foobarz'

  #canvas = $('#my_canvas')
  #context = canvas.context
  images = {}
  canvas = document.getElementById('my_canvas')
  console.log canvas
  context = canvas.getContext('2d')
  tiles = {
    blue: {
      '4': 2,
      '3': 3,
      '2-straight': 6,
      '2-turn': 5
    }
  }
  tile_stack = []
  for color, types of tiles
    console.log "color: #{color}, types: #{types}"
    for type, num of types
      console.log images["blue#{type}.png"]
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
      console.log "Drawing a #{tile} at #{this.setAtX*100}x#{this.setAtY*100}"
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
