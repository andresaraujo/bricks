library app.renderer;

import 'dart:html' as dom;
import 'package:bricks/src/grid.dart';
import 'package:bricks/src/tile.dart';
import 'package:bricks/src/position.dart';

class HTMLActuator {

  dom.Element tileContainer    = dom.querySelector(".tile-container");
  dom.Element scoreContainer   = dom.querySelector(".score-container");
  dom.Element bestContainer    = dom.querySelector(".best-container");
  dom.Element messageContainer = dom.querySelector(".game-message");

  int score = 0;

  void actuate (Grid grid, Map<String, Object> metadata) {

    dom.window.requestAnimationFrame((_) {
      clearContainer(tileContainer);

      grid.cells.forEach((column) {
        column.forEach((cell) {
          if (cell != null) {
            addTile(cell);
          }
        });
      });

      updateScore(metadata['score']);
      updateBestScore(metadata['bestScore']);

      if (metadata['terminated']) {
        if (metadata['over']) {
          message(false); // You lose
        } else if (metadata['won']) {
          message(true); // You win!
        }
      }

    });
  }

  void continueGame() {
    clearMessage();
  }

  void clearContainer(dom.Element container) {
    while (container.firstChild != null) {
      container.firstChild.remove();
    }
  }

  void addTile(Tile tile) {

    var wrapper   = new dom.DivElement();
    var inner     = new dom.DivElement();
    var position  = tile.previousPosition != null ?
                    tile.previousPosition : new Position(tile.position.x, tile.position.y);
    String _positionClass = this.positionClass(position);

    // We can't use classlist because it somehow glitches when replacing classes
    List<String> classes = ["tile", "tile-${tile.value}", _positionClass];

    if (tile.value > 2048) classes.add("tile-super");

    this.applyClasses(wrapper, classes);

    inner.classes.add("tile-inner");
    inner.text = "${tile.value}";

    if (tile.previousPosition != null) {
      // Make sure that the tile gets rendered in the previous position first
      dom.window.requestAnimationFrame((_) {
        classes[2] = this.positionClass(new Position(tile.position.x, tile.position.y));
        applyClasses(wrapper, classes); // Update the position
      });
    } else if (tile.mergedFrom != null) {
      classes.add("tile-merged");
      this.applyClasses(wrapper, classes);

      // Render the tiles that merged
      tile.mergedFrom.forEach((merged) {
        addTile(merged);
      });
    } else {
      classes.add("tile-new");
      this.applyClasses(wrapper, classes);
    }

    // Add the inner part of the tile to the wrapper
    wrapper.children.add(inner);

    // Put the tile on the board
    this.tileContainer.children.add(wrapper);
  }

  void applyClasses(dom.Element element, List<String> classes) {
    element.setAttribute("class", classes.join(" "));
  }

  Position normalizePosition(Position position) {
    return new Position(position.x + 1, position.y + 1 );
  }

  String positionClass(Position position) {
    position = normalizePosition(position);
    return "tile-position-${position.x}-${position.y}";
  }

  void updateScore(int score) {
    clearContainer(this.scoreContainer);

    var difference = score - this.score;
    this.score = score;

    this.scoreContainer.text = "${this.score}";

    if (difference > 0) {
      var addition = new dom.DivElement();
      addition.classes.add("score-addition");
      addition.text = "+$difference";

      this.scoreContainer.children.add(addition);
    }
  }

  void updateBestScore(int bestScore) {
    this.bestContainer.text = "$bestScore";
  }

  void message(bool won) {
    var type    = won ? "game-won" : "game-over";
    var message = won ? "You win!" : "Game over!";

    this.messageContainer.classes.add(type);
    this.messageContainer.querySelector("p").children[0].text = message;
  }

  void clearMessage() {
    // IE only takes one value to remove at a time.
    this.messageContainer.classes.remove("game-won");
    this.messageContainer.classes.remove("game-over");
  }
}