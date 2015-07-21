// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html' as dom;
import 'package:2048/2048.dart';

void main() {
  Grid grid = new Grid(5);
  print(grid.cells);
  print(grid.randomAvailableCell());

  dom.window.requestAnimationFrame((_){
    new GameManager(4, new HTMLActuator(), new KeyboardInputManager());
  });
}
