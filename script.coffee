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
  x = 0
  y = 0
  tile_list = []
  console.log tiles
  for color, types of tiles
    console.log "color: #{color}, types: #{types}"
    for type, num of types
      name = "blue#{type}.png"
      images[name] = new Image
      images[name].src = name
      for i in [1..num] by 1
        tile_list.push "#{color}#{type}.png"

  for tile in tile_list
    console.log "Drawing a #{tile} at #{x*100}x#{y*100}"
    context.drawImage(images[tile],x*100,y*100, 100,100)
    if x < 9
      x = x+1
    else
      x = 0
      y = y + 1
