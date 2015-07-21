library app.tile;

import 'package:2048/src/position.dart';

class Tile {
  Position position;
  int value;

  Position previousPosition =  null;
  List<Tile> mergedFrom = null;

  Tile(this.position, [this.value =  2]);

  savePosition() {
    previousPosition = new Position(position.x, position.y);
  }

  updatePosition(Position position) {
    this.position = position;
  }
}