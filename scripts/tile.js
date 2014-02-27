// Generated by CoffeeScript 1.6.3
(function() {
  var Tile, fisherYates;

  fisherYates = require('./fisher');

  module.exports = Tile = (function() {
    function Tile(color, type, size, board) {
      this.color = color;
      this.type = type;
      this.size = size;
      this.board = board;
      if (this.color === 'start') {
        this.name = 'images/start.png';
        this.x = 0;
        this.y = 0;
        this.set_exits();
      } else {
        this.orientations = this.rotations();
        fisherYates(this.orientations);
        this.rotate(this.orientations.pop());
      }
      if (this.size === 121) {
        this.offset = 8;
      } else {
        this.offset = 16;
      }
    }

    Tile.prototype.draw = function(context) {
      var _this = this;
      this.img = new Image;
      this.img.setAtX = this.x + this.offset;
      this.img.setAtY = -1 * this.y + this.offset;
      this.img.onload = function() {
        return context.drawImage(_this.img, _this.img.setAtX * _this.size, _this.img.setAtY * _this.size, _this.size, _this.size);
      };
      this.img.src = this.name;
      return this;
    };

    Tile.prototype.rotations = function() {
      switch (this.type) {
        case '1':
          return [1, 2, 3, 4];
        case '2-straight':
          return [1, 2];
        case '2-turn':
          return [1, 2, 3, 4];
        case '3':
          return [1, 2, 3, 4];
        case '4':
          return [1];
      }
    };

    Tile.prototype.set_exits = function() {
      switch (this.type) {
        case '1':
          this.east = this.orientation === 3;
          this.west = this.orientation === 1;
          this.north = this.orientation === 2;
          return this.south = this.orientation === 4;
        case '2-straight':
          this.east = this.orientation === 1;
          this.west = this.orientation === 1;
          this.north = this.orientation === 2;
          return this.south = this.orientation === 2;
        case '2-turn':
          this.east = this.orientation === 1 || this.orientation === 4;
          this.west = this.orientation === 2 || this.orientation === 3;
          this.north = this.orientation === 3 || this.orientation === 4;
          return this.south = this.orientation === 1 || this.orientation === 2;
        case '3':
          this.east = this.orientation === 1 || this.orientation === 2 || this.orientation === 3;
          this.west = this.orientation === 1 || this.orientation === 3 || this.orientation === 4;
          this.north = this.orientation === 1 || this.orientation === 2 || this.orientation === 4;
          return this.south = this.orientation === 2 || this.orientation === 3 || this.orientation === 4;
        case '4':
          this.east = true;
          this.west = true;
          this.north = true;
          return this.south = true;
      }
    };

    Tile.prototype.rotate = function(orientation) {
      this.orientation = orientation;
      this.name = "images/" + this.color + this.type + "-" + this.orientation + ".png";
      return this.set_exits();
    };

    Tile.prototype.place = function() {
      var east_tile, fits, i, north_tile, slot, slots, south_tile, west_tile, x, y, _i, _len;
      slots = this.board.find_valid_openings();
      fisherYates(slots);
      i = 0;
      for (_i = 0, _len = slots.length; _i < _len; _i++) {
        slot = slots[_i];
        while (true) {
          x = slot[0];
          y = slot[1];
          north_tile = this.board.tile_at(x, y + 1);
          east_tile = this.board.tile_at(x + 1, y);
          south_tile = this.board.tile_at(x, y - 1);
          west_tile = this.board.tile_at(x - 1, y);
          fits = true;
          if (north_tile && (north_tile.south !== this.north)) {
            fits = false;
          }
          if (east_tile && (east_tile.west !== this.east)) {
            fits = false;
          }
          if (south_tile && (south_tile.north !== this.south)) {
            fits = false;
          }
          if (west_tile && (west_tile.east !== this.west)) {
            fits = false;
          }
          if (fits) {
            this.x = x;
            this.y = y;
            this.board.add_tile(this);
            this.board.last_was_placeable = true;
            return true;
          }
          if (this.orientations.length === 0) {
            break;
          }
          this.rotate(this.orientations.pop());
        }
      }
      this.board.unplaceable.push(this);
      this.board.last_was_placeable = false;
      return false;
    };

    return Tile;

  })();

}).call(this);