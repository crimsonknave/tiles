(function() {
  var $, Board, board, build_map, fisherYates;

  $ = require('jquery-1.10.2');

  fisherYates = require('fisher');

  Board = require('board');

  board = false;

  console.log('foo');

  $(document).ready(function() {
    $('.toggle').click(function() {
      $('.toggle').toggleClass('hidden');
      return $('.config').toggleClass('collapsed');
    });
    $('#my_canvas').mousedown(function(e) {
      var canvas_x, canvas_y, tile;
      if (!board) {
        return;
      }
      canvas_x = e.pageX - $(this).offset().left;
      canvas_y = e.pageY - $(this).offset().top;
      tile = board.tile_at_canvas_coords(canvas_x, canvas_y);
      if (tile) {
        return tile.toggle();
      }
    });
    $('.save').click(function() {
      var image, lnk;
      image = canvas.toDataURL('map.png').replace('image/png', 'image/octet-stream');
      if (!this.lnk) {
        lnk = document.createElement('a');
      }
      lnk.download = 'map.png';
      lnk.href = image;
      return lnk.click();
    });
    return $('.submit').click(function() {
      var interval, size, tiles;
      size = parseInt($('.size').val());
      interval = parseInt($('.interval').val());
      tiles = {
        '4': parseInt($('.4').val()) || 0,
        '3': parseInt($('.3').val()) || 0,
        '2-straight': parseInt($('.2-straight').val()) || 0,
        '2-turn': parseInt($('.2-turn').val()) || 0,
        '1': parseInt($('.1').val()) || 0
      };
      return build_map(tiles, size, interval);
    });
  });

  build_map = function(tiles, size, interval) {
    var canvas, context, stopping;
    canvas = document.getElementById('my_canvas');
    context = canvas.getContext('2d');
    if (board) {
      board.stop_placing = true;
    }
    return stopping = setInterval((function() {
      var number_of_zones, selected_zones, zones;
      if (board && board.running) {

      } else {
        context.clearRect(0, 0, 2057, 2057);
        number_of_zones = $('select.zones').val();
        zones = ['first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth'];
        selected_zones = zones.slice(0, number_of_zones);
        board = new Board(context, size, tiles, selected_zones, interval);
        board.add_start_tile();
        board.lay_tiles();
        return clearInterval(stopping);
      }
    }), 10);
  };

}).call(this);
