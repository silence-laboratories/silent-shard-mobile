// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

abstract mixin class DemoDecorator {
  bool isDemoActive = false;

  void startDemoMode() {
    isDemoActive = true;
  }

  void stopDemoMode() {
    isDemoActive = false;
  }
}
