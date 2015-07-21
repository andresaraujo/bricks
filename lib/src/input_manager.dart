library app.input_manager;

import 'dart:html' as dom;
import 'dart:math' as math;

class KeyboardInputManager {
  Map<String, List> events = {};

  KeyboardInputManager() {
    listen();
  }

  on(String event, Function callback) {
    if (events[event] == null) {
      this.events[event] = [];
    }
    this.events[event].add(callback);
  }

  emit(String event, [data = null]) {
    List<Function> callbacks = events[event];

    if(callbacks != null) {
      callbacks.forEach((callback) {
        if(data != null) {
          callback(data);
        } else {
          callback();
        }
      });
    }
  }

  void listen() {
    var map = {
      dom.KeyCode.UP: 0, // Up
      dom.KeyCode.RIGHT: 1, // Right
      dom.KeyCode.DOWN: 2, // Down
      dom.KeyCode.LEFT: 3, // Left
      75: 0, // Vim up
      76: 1, // Vim right
      74: 2, // Vim down
      72: 3, // Vim left
      dom.KeyCode.W: 0, // W
      dom.KeyCode.D: 1, // D
      dom.KeyCode.S: 2, // S
      dom.KeyCode.A: 3  // A
    };

    dom.document.onKeyDown.listen((evt){
      var modifiers = evt.altKey || evt.ctrlKey || evt.metaKey ||
      evt.shiftKey;
      var mapped = map[evt.which];

      if (!modifiers) {
        if (mapped != null) {
          evt.preventDefault();
          emit("move", mapped);
        }
      }

      // R key restarts the game
      if (!modifiers && evt.which == dom.KeyCode.R) {
        restart(evt);
      }
    });

    // Respond to button presses
    bindButtonPress(".retry-button", restart);
    bindButtonPress(".restart-button", restart);
    bindButtonPress(".keep-playing-button", keepPlaying);

    // Respond to swipe events
    var touchStartClientX, touchStartClientY;
    var gameContainer = dom.querySelector(".game-container");

    gameContainer.onTouchStart.listen((event) {
      touchStartClientX = event.touches[0].client.x;
      touchStartClientY = event.touches[0].client.y;
      event.preventDefault();
    });

    gameContainer.onTouchMove.listen((event) => event.preventDefault());

    gameContainer.onTouchEnd.listen((event) {

      var touchEndClientX, touchEndClientY;

      touchEndClientX = event.changedTouches[0].client.x;
      touchEndClientY = event.changedTouches[0].client.y;

      num dx = touchEndClientX - touchStartClientX;
      var absDx = dx.abs();

      num dy = touchEndClientY - touchStartClientY;
      var absDy = dy.abs();

      if (math.max(absDx, absDy) > 10) {
        // (right : left) : (down : up)
        emit("move", absDx > absDy ? (dx > 0 ? 1 : 3) : (dy > 0 ? 2 : 0));
      }
    });
  }

  void restart(dom.Event event) {
    event.preventDefault();
    emit("restart");
  }

  keepPlaying(dom.Event event) {
    event.preventDefault();
    emit("keepPlaying");
  }

  bindButtonPress(String selector, void callback(event)) {
    var button = dom.querySelector(selector);
    button.onClick.listen(callback);
    button.onTouchEnd.listen(callback);
  }
}

