(function() {
  var $, Tile, fisherYates, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  fisherYates = require('fisher');

  $ = require('jquery-1.10.2');

  _ = require('underscore-min');

  module.exports = Tile = (function() {
    function Tile(zone, type, size, board, id) {
      this.zone = zone;
      this.type = type;
      this.size = size;
      this.board = board;
      this.id = id != null ? id : false;
      this.toggle = __bind(this.toggle, this);
      if (this.zone === 'start') {
        this.file = 'images/start.png';
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

    Tile.prototype.neighbor_to_the = function(dir) {
      var x, y;
      switch (dir) {
        case 'north':
          x = this.x;
          y = this.y + 1;
          break;
        case 'east':
          x = this.x + 1;
          y = this.y;
          break;
        case 'south':
          x = this.x;
          y = this.y - 1;
          break;
        case 'west':
          x = this.x - 1;
          y = this.y;
      }
      return this.board.tile_at(x, y);
    };

    Tile.prototype.empty_exits = function() {
      var exits;
      exits = [];
      if (this.north && !this.neighbor_to_the('north')) {
        exits.push(['N']);
      }
      if (this.east && !this.neighbor_to_the('east')) {
        exits.push(['E']);
      }
      if (this.west && !this.neighbor_to_the('west')) {
        exits.push(['W']);
      }
      if (this.south && !this.neighbor_to_the('south')) {
        exits.push(['S']);
      }
      return exits.join(', ');
    };

    Tile.prototype.exit_list = function() {
      var exits;
      exits = [];
      if (this.north) {
        exits.push(['N']);
      }
      if (this.east) {
        exits.push(['E']);
      }
      if (this.west) {
        exits.push(['W']);
      }
      if (this.south) {
        exits.push(['S']);
      }
      return exits.join(', ');
    };

    Tile.prototype.canvas_rect = function() {
      var rect, x, x_shift, y, y_shift;
      rect = [];
      x = this.x * this.board.size;
      x_shift = this.board.x * this.board.size;
      y = this.y * this.board.size;
      y_shift = this.board.y * this.board.size;
      rect.push(x + x_shift);
      rect.push((-1 * y) + y_shift);
      rect.push(this.board.size);
      rect.push(this.board.size);
      return rect;
    };

    Tile.prototype.toggle = function() {
      var rect;
      this.toggled = !this.toggled;
      this.board.context.save();
      if (this.toggled) {
        this.board.context.globalAlpha = 0.5;
      }
      rect = this.canvas_rect();
      this.board.context.clearRect(rect[0], rect[1], rect[2], rect[3]);
      this.board.context.drawImage(this.img, this.img.setAtX * this.size, this.img.setAtY * this.size, this.size, this.size);
      this.board.context.restore();
      return $.get('templates/info.html', (function(_this) {
        return function(data) {
          var html, info;
          html = _.template(data, _this);
          info = $('.info');
          info.html(html);
          return info.removeClass('hidden');
        };
      })(this), 'html');
    };

    Tile.prototype.draw = function() {
      this.img = new Image;
      this.img.setAtX = this.x + this.offset;
      this.img.setAtY = -1 * this.y + this.offset;
      this.img.onload = (function(_this) {
        return function() {
          return _this.board.context.drawImage(_this.img, _this.img.setAtX * _this.size, _this.img.setAtY * _this.size, _this.size, _this.size);
        };
      })(this);
      this.img.src = this.file;
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
      this.file = "images/" + this.zone + this.type + "-" + this.orientation + ".png";
      return this.set_exits();
    };

    Tile.prototype.place = function() {
      var all_slots, east_tile, fits, i, key, matching_slots, north_tile, other_slots, slot, slots, south_tile, value, west_tile, x, y, _i, _len;
      slots = this.board.find_valid_openings();
      other_slots = [];
      for (key in slots) {
        value = slots[key];
        if (key === this.zone) {
          if (value.length > 0) {
            matching_slots = value;
          } else {
            matching_slots = [];
          }
        } else {
          if (value.length > 0) {
            other_slots = other_slots.concat(value);
          }
        }
      }
      fisherYates(matching_slots);
      fisherYates(other_slots);
      all_slots = matching_slots.concat(other_slots);
      i = 0;
      for (_i = 0, _len = all_slots.length; _i < _len; _i++) {
        slot = all_slots[_i];
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
