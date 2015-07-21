library app.game_manager;

import 'dart:math' as math;
import 'package:bricks/src/position.dart';
import 'package:bricks/src/tile.dart';
import 'package:bricks/src/grid.dart';
import 'package:bricks/src/html_actuator.dart';
import 'package:bricks/src/input_manager.dart';

class GameManager {
  int size;
  Grid grid;

  int startTiles = 2;
  int score = 0;
  bool over = false;
  bool won = false;
  bool _keepPlaying = false;

  HTMLActuator actuator;
  KeyboardInputManager inputManager;

  GameManager(this.size, this.actuator, this.inputManager) {

    inputManager.on("move", move);
    inputManager.on("restart", restart);
    inputManager.on("keepPlaying", keepPlaying);
    setup();
  }

  // Restart the game
  void restart() {
    print("gamemanager: restart");
    //this.storageManager.clearGameState();
    actuator.continueGame(); // Clear the game won/lost message
    setup();
  }

// Keep playing after winning (allows going over 2048)
  void keepPlaying() {
    _keepPlaying = true;
    actuator.continueGame(); // Clear the game won/lost message
  }

  bool isGameTerminated() {
    return over || (won && !_keepPlaying);
  }

  void setup(){
    GameManager prevState = null; //todo: get saved state
    if(prevState != null) {
      grid = new Grid(prevState.grid.size, prevState.grid.cells);
      score = prevState.score;
      over = prevState.over;
      won = prevState.won;
      _keepPlaying = prevState._keepPlaying;

    } else {
      grid = new Grid(size);
      score = 0;
      over = false;
      won = false;
      _keepPlaying = false;

      addStartTiles();
    }

    actuate();
  }

  void addStartTiles() {
    for(var i = 0; i < startTiles; i++) {
      addRandomTile();
    }
  }
  void addRandomTile() {
    if(grid.cellsAvailable()) {
      var value = new math.Random().nextDouble() < 0.9 ? 2 : 4;
      var tile = new Tile(grid.randomAvailableCell(), value);
      grid.insertTile(tile);
    }
  }

  void actuate() {
    /*if (this.storageManager.getBestScore() < this.score) {
      this.storageManager.setBestScore(this.score);
    }*/

    // Clear the state when the game is over (game over only, not win)
    /*if (this.over) {
      this.storageManager.clearGameState();
    } else {
      this.storageManager.setGameState(this.serialize());
    }*/

    this.actuator.actuate(grid, {
      'score':      score,
      'over':       over,
      'won':        won,
      'bestScore':  0, //this.storageManager.getBestScore(),
      'terminated': isGameTerminated()
    });

  }

  //serialize

  void prepareTiles() {
    grid.eachCell((x, y, tile) {
      if(tile != null) {
        tile.mergedFrom = null;
        tile.savePosition();
      }
    });
  }

  void moveTile(Tile tile, Position cell) {
    grid.cells[tile.position.x][tile.position.y] = null;
    grid.cells[cell.x][cell.y] = tile;
    tile.updatePosition(cell);
  }

  void move(int direction) {
    if (isGameTerminated()) return; // Don't do anything if the game's over

    var cell;
    Tile tile;

    var vector     = this.getDirectionVector(direction);
    var traversals = this.buildTraversals(vector);
    var moved      = false;

    // Save the current tile positions and remove merger information
    prepareTiles();

    // Traverse the grid in the right direction and move tiles
    traversals['x'].forEach((x) {
      traversals['y'].forEach((y) {
        cell = new Position(x, y);
        tile = grid.cellContent(cell.x, cell.y);

        if(tile != null) {
          Map<String, Position> positions = findFarthestPosition(cell, vector);
          Tile next = grid.cellContent(positions['next'].x, positions['next'].y);

          // Only one merger per row traversal?
          if (next != null && next.value == tile.value && next.mergedFrom == null) {
            var merged = new Tile(positions['next'], tile.value * 2);
            merged.mergedFrom = [tile, next];

            grid.insertTile(merged);
            grid.removeTile(tile);

            // Converge the two tiles' positions
            tile.updatePosition(positions['next']);

            // Update the score
            score += merged.value;

            // The mighty 2048 tile
            if (merged.value == 2048) won = true;
          } else {
            moveTile(tile, positions['farthest']);
          }

          if (!positionsEqual(cell, tile.position)) {
            moved = true; // The tile moved from its original cell!
          }
        }
      });
    });

    if (moved) {
      addRandomTile();

      if (!movesAvailable()) {
        this.over = true; // Game over!
      }

      actuate();
    }
  }

  Position getDirectionVector(int direction) {
    switch(direction) {
      case 0: return new Position(0, -1);
      case 1: return new Position(1, 0);
      case 2: return new Position(0, 1);
      case 3: return new Position(-1, 0);
      default: print("Direction must be an integer from 0 to 3");
      return null;
    }
  }

  Map<String, List<int>> buildTraversals(Position vector) {
    var traversals = <String, List<int>>{
      'x': [],
      'y': []
    };

    for (var pos = 0; pos < this.size; pos++) {
      traversals['x'].add(pos);
      traversals['y'].add(pos);
    }

    // Always traverse from the farthest cell in the chosen direction
    if (vector.x == 1) traversals['x'] = traversals['x'].reversed;
    if (vector.y == 1) traversals['y'] = traversals['y'].reversed;

    return traversals;
  }

  Map<String, Position> findFarthestPosition (Position cell, Position vector) {
    var previous;

    // Progress towards the vector direction until an obstacle is found
    do {
      previous = cell;
      cell     = new Position(previous.x + vector.x, previous.y + vector.y );
    } while (grid.withinBounds(cell.x, cell.y) && grid.cellAvailable(cell));

    return {
      'farthest': previous,
      'next': cell // Used to check if a merge is required
    };
  }

  bool movesAvailable() => grid.cellsAvailable() || tileMatchesAvailable();

  bool tileMatchesAvailable() {

    var tile = null;
    for (var x = 0; x < this.size; x++) {
      for (var y = 0; y < this.size; y++) {
        tile = grid.cellContent(x, y);

        if(tile != null) {
          for(var direction = 0; direction < 4; direction++) {
            Position vector = getDirectionVector(direction);
            Position cell = new Position(x + vector.x, y + vector.y);

            var other = grid.cellContent(cell.x, cell.y);

            if(other != null && other.value == tile.value) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  bool positionsEqual(Position first, Position second) {
    return first.x == second.x && first.y == second.y;
  }
}