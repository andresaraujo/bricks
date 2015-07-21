library app.position;

class Position {
  int x, y;
  Position(this.x, this.y);
  toString() => '{"x": $x, "y": $y}';
}