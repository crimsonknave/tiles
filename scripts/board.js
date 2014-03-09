(function() {
  var $, Board, Tile, fisherYates;

  Tile = require('tile');

  $ = require('jquery-1.10.2');

  fisherYates = require('fisher');

  module.exports = Board = (function() {
    function Board(context, size, tile_list, zones, interval) {
      this.context = context;
      this.size = size;
      this.tile_list = tile_list;
      this.zones = zones;
      this.interval = interval;
      this.tiles = {};
      this.count = 0;
      this.last_was_placeable = true;
      this.unplaceable = [];
      if (this.size === 60) {
        this.x = 16;
        this.y = 16;
      } else {
        this.x = 8;
        this.y = 8;
      }
    }

    Board.prototype.add_start_tile = function() {
      var start_tile;
      start_tile = new Tile('start', '4', this.size, this);
      return this.add_tile(start_tile);
    };

    Board.prototype.add_tile = function(tile) {
      var obj;
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
      tile.draw();
      return tile.placement_id = this.count;
    };

    Board.prototype.wall_at = function(x, y) {
      return Math.abs(x) > this.x || Math.abs(y) > this.y;
    };

    Board.prototype.tile_at_canvas_coords = function(x, y) {
      var board_x, board_y;
      board_x = Math.floor(x / this.size) - this.x;
      board_y = -1 * (Math.floor(y / this.size) - this.y);
      return this.tile_at(board_x, board_y);
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
      openings = {
        'start': [],
        'first': [],
        'second': [],
        'third': [],
        'fourth': [],
        'fifth': [],
        'sixth': [],
        'seventh': [],
        'eighth': [],
        'ninth': []
      };
      _ref = this.tiles;
      for (x in _ref) {
        tiles = _ref[x];
        for (y in tiles) {
          tile = tiles[y];
          if (tile.north) {
            coords = [tile.x, tile.y + 1];
            if (!(this.tile_at.apply(this, coords) || this.wall_at.apply(this, coords))) {
              openings[tile.zone].push(coords);
            }
          }
          if (tile.east) {
            coords = [tile.x + 1, tile.y];
            if (!(this.tile_at.apply(this, coords) || this.wall_at.apply(this, coords))) {
              openings[tile.zone].push(coords);
            }
          }
          if (tile.south) {
            coords = [tile.x, tile.y - 1];
            if (!(this.tile_at.apply(this, coords) || this.wall_at.apply(this, coords))) {
              openings[tile.zone].push(coords);
            }
          }
          if (tile.west) {
            coords = [tile.x - 1, tile.y];
            if (!(this.tile_at.apply(this, coords) || this.wall_at.apply(this, coords))) {
              openings[tile.zone].push(coords);
            }
          }
        }
      }
      return openings;
    };

    Board.prototype.lay_tiles = function() {
      var i, num, stack, tile, tile_stack, timer, type, zone, _i, _j, _len, _ref, _ref1;
      this.stop_placing = false;
      this.running = true;
      tile_stack = [];
      this.unplaceable = [];
      this.last_was_placeable = true;
      _ref = this.zones.reverse();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        zone = _ref[_i];
        stack = [];
        _ref1 = this.tile_list;
        for (type in _ref1) {
          num = _ref1[type];
          for (i = _j = 1; _j <= num; i = _j += 1) {
            tile = new Tile(zone, type, this.size, this);
            stack.push(tile);
          }
        }
        fisherYates(stack);
        tile_stack = tile_stack.concat(stack);
      }
      $('span.max').text(tile_stack.length);
      $('span.min').removeClass('green');
      $('span.min').removeClass('red');
      return timer = setInterval(((function(_this) {
        return function() {
          var next_tile;
          if (_this.stop_placing) {
            console.log('Stopping as requested');
            clearInterval(timer);
            _this.running = false;
            return false;
          }
          if (tile_stack.length === 0 && (!_this.last_was_placeable || _this.unplaceable.length === 0)) {
            console.log('Placed the last tile');
            console.log(tile_stack);
            console.log(_this.unplaceable);
            if (_this.unplaceable.length > 0) {
              $('span.min').addClass('red');
            } else {
              $('span.min').addClass('green');
            }
            console.log("Placed " + _this.count + " tiles");
            clearInterval(timer);
            _this.running = false;
          }
          if (_this.unplaceable.length > 0 && _this.last_was_placeable) {
            next_tile = _this.unplaceable.pop();
          } else {
            next_tile = tile_stack.pop();
          }
          if (next_tile) {
            next_tile.place();
            return $('span.min').text(_this.count - 1);
          }
        };
      })(this)), this.interval);
    };

    return Board;

  })();

}).call(this);
