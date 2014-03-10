(function() {
  var tile;

  tile = require('tile');

  describe('Tile', function() {
    return it('should exist', function() {
      console.log(tile);
      return tile.should.exist();
    });
  });

}).call(this);
