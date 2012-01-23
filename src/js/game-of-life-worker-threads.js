(function() {
  var GOLWT;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  GOLWT = (function() {
    function GOLWT(element_id) {
      var canvas, element, i, key, nbx, nby, nx, ny, value, worker, x, y, _ref;
      element = document.getElementById(element_id);
      canvas = document.createElement("canvas");
      canvas.setAttribute("width", "500px");
      canvas.setAttribute("height", "250px");
      element.appendChild(canvas);
      this.ctx = canvas.getContext("2d");
      this.jobs_running = 0;
      this.nr_of_workers = 1;
      this.workers = [];
      for (i = 0, _ref = this.nr_of_workers; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        worker = new Worker('/src/js/worker.js');
        worker.onmessage = __bind(function(e) {
          return this.receive_message(e.data);
        }, this);
        this.workers.push(worker);
      }
      this.grid = {};
      for (x = 0; x < 100; x++) {
        for (y = 0; y < 50; y++) {
          key = "" + x + "_" + y;
          value = parseInt(Math.random() * 10) % 2;
          this.grid[key] = {
            "value": value,
            "age": 0,
            "neighbours": []
          };
          for (nx = -1; nx <= 1; nx++) {
            for (ny = -1; ny <= 1; ny++) {
              if (ny === 0 && nx === 0) {
                continue;
              }
              nbx = x + nx;
              if (nbx === -1) {
                nbx = 99;
              }
              if (nbx === 100) {
                nbx = 0;
              }
              nby = y + ny;
              if (nby === -1) {
                nby = 49;
              }
              if (nby === 50) {
                nby = 0;
              }
              this.grid[key]["neighbours"].push("" + nbx + "_" + nby);
            }
          }
        }
      }
      this.tmp_grid = this.copy_grid(this.grid);
    }
    GOLWT.prototype.copy_grid = function(grid) {
      var cell, key, result;
      result = {};
      for (key in grid) {
        cell = grid[key];
        result[key] = {
          "value": cell["value"],
          "age": cell["age"],
          "neighbours": cell["neighbours"]
        };
      }
      return result;
    };
    GOLWT.prototype.send_message = function(worker_id, message_data) {
      return this.workers[worker_id].postMessage(message_data);
    };
    GOLWT.prototype.receive_message = function(data) {
      var key, msg, value;
      msg = data;
      for (key in msg) {
        value = msg[key];
        this.tmp_grid[key]["value"] = value;
      }
      return this.jobs_running--;
    };
    GOLWT.prototype.run = function() {
      var cell, key, worker_id, x, y, _ref, _ref2, _ref3;
      if (this.jobs_running === 0) {
        this.ctx.clearRect(0, 0, 500, 250);
        this.grid = this.copy_grid(this.tmp_grid);
        _ref = this.grid;
        for (key in _ref) {
          cell = _ref[key];
          if (cell["value"]) {
            _ref2 = key.split("_"), x = _ref2[0], y = _ref2[1];
            this.ctx.fillRect(x * 5, y * 5, 5, 5);
          }
        }
        this.jobs_running = this.nr_of_workers;
        for (worker_id = 0, _ref3 = this.nr_of_workers; 0 <= _ref3 ? worker_id < _ref3 : worker_id > _ref3; 0 <= _ref3 ? worker_id++ : worker_id--) {
          this.send_message(worker_id, {
            "index": worker_id,
            "step": this.nr_of_workers,
            "grid": this.grid
          });
        }
      }
      return window.webkitRequestAnimationFrame(__bind(function() {
        return this.run();
      }, this));
    };
    return GOLWT;
  })();
  window.GOLWT = GOLWT;
}).call(this);
