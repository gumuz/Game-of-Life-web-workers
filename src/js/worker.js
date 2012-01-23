(function() {
  var GOLWTWorker, worker;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  GOLWTWorker = (function() {
    function GOLWTWorker() {
      self.onmessage = __bind(function(e) {
        var msg;
        msg = JSON.parse(e.data);
        return this.work(msg["grid"], msg["index"], msg["step"]);
      }, this);
    }
    GOLWTWorker.prototype.work = function(grid, index, step) {
      var changed, key, nb_alive, nbkey, x, y, _i, _len, _ref;
      changed = {};
      for (x = index; index <= 50 ? x < 50 : x > 50; x += step) {
        for (y = 0; y < 50; y++) {
          key = "" + x + "_" + y;
          nb_alive = 0;
          _ref = grid[key]["neighbours"];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            nbkey = _ref[_i];
            nb_alive += grid[nbkey]["value"];
          }
          if (grid[key]["value"]) {
            if (nb_alive < 2 || nb_alive > 3) {
              changed[key] = 0;
            }
          } else {
            if (nb_alive === 3) {
              changed[key] = 1;
            }
          }
        }
      }
      return postMessage(JSON.stringify(changed));
    };
    return GOLWTWorker;
  })();
  worker = new GOLWTWorker();
}).call(this);
