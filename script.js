// Generated by CoffeeScript 1.6.3
(function() {
  var $, Board, Tile, fisherYates, lay_random_tiles;

  $ = jQuery;

  lay_random_tiles = function(tiles, board) {
    var color, i, insert_tile, num, tile_stack, timer, type, types, _i;
    tile_stack = [];
    for (color in tiles) {
      types = tiles[color];
      for (type in types) {
        num = types[type];
        for (i = _i = 1; _i <= num; i = _i += 1) {
          tile_stack.push("" + color + type + ".png");
        }
      }
    }
    fisherYates(tile_stack);
    insert_tile = function(t, count) {
      var east, east_tile, fits, north, north_tile, selected_slot, slots, south, south_tile, tile, west, west_tile, x, y;
      if (count == null) {
        count = 0;
      }
      slots = board.find_valid_openings();
      selected_slot = slots[Math.floor(Math.random() * slots.length)];
      x = selected_slot[0];
      y = selected_slot[1];
      switch (t) {
        case 'blue2-straight.png':
          east = true;
          west = true;
          north = false;
          south = false;
          break;
        case 'blue2-turn.png':
          east = true;
          west = false;
          north = true;
          south = false;
          break;
        case 'blue3.png':
          east = true;
          west = true;
          north = true;
          south = false;
          break;
        case 'blue4.png':
          east = true;
          west = true;
          north = true;
          south = true;
      }
      north_tile = board.tile_at(x, y + 1);
      console.log("north: " + north_tile);
      east_tile = board.tile_at(x + 1, y);
      console.log("east: " + east_tile);
      south_tile = board.tile_at(x, y - 1);
      console.log("south: " + south_tile);
      west_tile = board.tile_at(x - 1, y);
      console.log("west: " + west_tile);
      console.log('--------');
      fits = true;
      if (north_tile && (north_tile.south !== north)) {
        fits = false;
      }
      if (east_tile && (east_tile.west !== east)) {
        fits = false;
      }
      if (south_tile && (south_tile.north !== south)) {
        fits = false;
      }
      if (west_tile && (west_tile.east !== west)) {
        fits = false;
      }
      if (fits) {
        tile = new Tile(t, x, y, north, east, south, west);
        return board.add_tile(tile);
      } else {
        console.log("did not fit at x: " + x + " y: " + y);
        console.log(t);
        console.log('--------');
        if (count < 10) {
          return insert_tile(t, count + 1);
        } else {
          return console.log('ran out of tries');
        }
      }
    };
    return timer = setInterval((function() {
      if (tile_stack.length === 1) {
        console.log('Placed the last tile');
        clearInterval(timer);
      }
      return insert_tile(tile_stack.pop());
    }), 100);
  };

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

  Tile = (function() {
    function Tile(image, x, y, north, east, south, west) {
      this.image = image;
      this.x = x;
      this.y = y;
      this.north = north;
      this.east = east;
      this.south = south;
      this.west = west;
      this.offset = 7;
    }

    Tile.prototype.draw = function(context) {
      console.log("drawing " + this.image + ", at " + this.x + "x" + this.y);
      this.img = new Image;
      this.img.setAtX = this.x + this.offset;
      this.img.setAtY = -1 * this.y + this.offset;
      this.img.onload = function() {
        return context.drawImage(this, this.setAtX * 100, this.setAtY * 100, 100, 100);
      };
      this.img.src = this.image;
      return this;
    };

    return Tile;

  })();

  Board = (function() {
    function Board(context) {
      this.context = context;
      this.tiles = {};
      this.count = 0;
      this.x = 5;
      this.y = 5;
    }

    Board.prototype.add_start_tile = function() {
      var start_tile;
      start_tile = new Tile('start.png', 0, 0, true, true, true, true);
      return this.add_tile(start_tile);
    };

    Board.prototype.add_tile = function(tile) {
      var obj;
      console.log('tile_at');
      if (this.tile_at(tile.x, tile.y)) {
        return false;
      }
      if (this.tiles[tile.x]) {
        obj = this.tiles[tile.x];
        obj[tile.y] = tile;
      } else {
        obj = {};
        obj[tile.y] = tile;
        this.tiles[tile.x] = obj;
      }
      this.count += 1;
      return tile.draw(this.context);
    };

    Board.prototype.wall_at = function(x, y) {
      return Math.abs(x) > this.x || Math.abs(y) > this.y;
    };

    Board.prototype.tile_at = function(x, y) {
      var exists, ys;
      exists = false;
      ys = this.tiles[x];
      if (ys) {
        exists = ys[y];
      }
      return exists;
    };

    Board.prototype.tile_count = function() {
      return this.count;
    };

    Board.prototype.find_valid_openings = function() {
      var coords, openings, tile, tiles, x, y, _ref;
      openings = [];
      _ref = this.tiles;
      for (x in _ref) {
        tiles = _ref[x];
        for (y in tiles) {
          tile = tiles[y];
          if (tile.north) {
            coords = [tile.x, tile.y + 1];
            if (!(this.tile_at.apply(this, coords) || this.wall_at.apply(this, coords))) {
              openings.push(coords);
            }
          }
          if (tile.east) {
            coords = [tile.x + 1, tile.y];
            if (!(this.tile_at.apply(this, coords) || this.wall_at.apply(this, coords))) {
              openings.push(coords);
            }
          }
          if (tile.south) {
            coords = [tile.x, tile.y - 1];
            if (!(this.tile_at.apply(this, coords) || this.wall_at.apply(this, coords))) {
              openings.push(coords);
            }
          }
          if (tile.west) {
            coords = [tile.x - 1, tile.y];
            if (!(this.tile_at.apply(this, coords) || this.wall_at.apply(this, coords))) {
              openings.push(coords);
            }
          }
        }
      }
      return openings;
    };

    return Board;

  })();

  $(document).ready(function() {
    var board, canvas, context, tiles;
    canvas = document.getElementById('my_canvas');
    context = canvas.getContext('2d');
    tiles = {
      blue: {
        '4': 10,
        '3': 12,
        '2-straight': 15,
        '2-turn': 20
      }
    };
    board = new Board(context);
    board.add_start_tile();
    return lay_random_tiles(tiles, board);
  });

}).call(this);
