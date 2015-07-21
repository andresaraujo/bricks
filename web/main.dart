// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html' as dom;
import 'package:bricks/bricks.dart';

void main() {

  dom.window.requestAnimationFrame((_){
    new GameManager(4, new HTMLActuator(), new KeyboardInputManager());
  });
}
