// Generated by CoffeeScript 1.6.3
(function() {
  var $, fisherYates;

  $ = jQuery;

  $(document).ready(function() {
    var canvas, color, context, i, images, img, num, tile, tile_stack, tiles, type, types, x, y, _i, _j, _len, _results;
    console.log('foobarz');
    images = {};
    canvas = document.getElementById('my_canvas');
    console.log(canvas);
    context = canvas.getContext('2d');
    tiles = {
      blue: {
        '4': 2,
        '3': 3,
        '2-straight': 6,
        '2-turn': 5
      }
    };
    tile_stack = [];
    for (color in tiles) {
      types = tiles[color];
      console.log("color: " + color + ", types: " + types);
      for (type in types) {
        num = types[type];
        console.log(images["blue" + type + ".png"]);
        for (i = _i = 1; _i <= num; i = _i += 1) {
          tile_stack.push("" + color + type + ".png");
        }
      }
    }
    fisherYates(tile_stack);
    x = 0;
    y = 0;
    _results = [];
    for (_j = 0, _len = tile_stack.length; _j < _len; _j++) {
      tile = tile_stack[_j];
      img = new Image;
      img.setAtX = x;
      img.setAtY = y;
      img.onload = function() {
        console.log("Drawing a " + tile + " at " + (this.setAtX * 100) + "x" + (this.setAtY * 100));
        return context.drawImage(this, this.setAtX * 100, this.setAtY * 100, 100, 100);
      };
      img.src = tile;
      if (x < 9) {
        _results.push(x = x + 1);
      } else {
        x = 0;
        _results.push(y = y + 1);
      }
    }
    return _results;
  });

  fisherYates = function(arr) {
    var i, j, _ref, _results;
    i = arr.length;
    if (i === 0) {
      return false;
    }
    _results = [];
    while (--i) {
      j = Math.floor(Math.random() * (i + 1));
      _results.push((_ref = [arr[j], arr[i]], arr[i] = _ref[0], arr[j] = _ref[1], _ref));
    }
    return _results;
  };

}).call(this);
