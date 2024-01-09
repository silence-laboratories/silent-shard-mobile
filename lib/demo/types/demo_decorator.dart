abstract mixin class DemoDecorator {
  bool isDemoActive = false;

  void startDemoMode() {
    isDemoActive = true;
  }

  void stopDemoMode() {
    isDemoActive = false;
  }
}
