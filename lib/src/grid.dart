library app.grid;

import 'dart:math' as math;
import 'package:2048/src/tile.dart';
import 'package:2048/src/position.dart';

class Grid {
  var size;
  List<List<Tile>> cells;

  Grid(this.size, [previousState = null]) {
    cells = previousState != null ? fromState(previousState) : empty();
  }

  List<List> empty() {
    var cells = new List(size);
    for(int x = 0; x < size; x++) {
      cells[x] = [];
      for(int y = 0; y < size; y++) {
        cells[x].add(null);
      }
    }
    return cells;
  }

  List<List> fromState(List<List<Tile>> state) {
    var cells = new List(size);
    for(int x = 0; x < size; x++) {
      cells[x] = [];
      for(int y = 0; y < size; y++) {
        Tile tile = state[x][y];
        cells[x].add(tile != null ? new Tile(tile.position, tile.value) : null);
      }
    }
    return cells;
  }

  Position randomAvailableCell() {
    List<Position> _cells = availableCells();

    if(_cells.isNotEmpty) {
      var r = new math.Random();
      return _cells[r.nextInt(_cells.length)];
    }
    return null;
  }

  List<Position> availableCells() {
    List<Position> _cells = [];

    eachCell((x, y, tile) {
      if(tile == null) {
        _cells.add(new Position(x, y));
      }
    });

    return _cells;
  }

  void eachCell(void callback(int x, int y, Tile tile)) {
    for(int x = 0; x < size; x++) {
      for(int y = 0; y < size; y++) {
        callback(x, y, cells[x][y]);
      }
    }
  }

  bool cellsAvailable() {
    return availableCells().isNotEmpty;
  }

  bool cellAvailable(Position cell) {
    return !cellOccupied(cell);
  }

  bool cellOccupied(Position cell) {
    return cellContent(cell.x, cell.y) != null;
  }

  Tile cellContent(int x, int y) {
    if(withinBounds(x, y)) {
      return cells[x][y];
    }
    return null;
  }

  void insertTile(Tile tile) {
    cells[tile.position.x][tile.position.y] = tile;
  }

  void removeTile(Tile tile) {
    cells[tile.position.x][tile.position.y] = null;
  }

  bool withinBounds(int x, int y) {
    return x >= 0 && x < size &&
    y >= 0 && y < size;
  }
}