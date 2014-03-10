(function() {
  module.exports = function(arr) {
    var i, j, _ref, _results;
    if (!arr) {
      return false;
    }
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
