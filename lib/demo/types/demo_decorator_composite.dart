import 'demo_decorator.dart';

abstract class DemoDecoratorComposite with DemoDecorator {
  final List<DemoDecorator> _decorators = [];

  DemoDecoratorComposite([List<DemoDecorator> children = const []]) {
    _decorators.addAll(children);
  }

  void addChild(DemoDecorator child) => _decorators.add(child);

  void removeChild(DemoDecorator child) => _decorators.remove(child);

  void removeChildAt(int index) => _decorators.removeAt(index);

  void removeChildren() => _decorators.removeRange(0, _decorators.length);

  @override
  void startDemoMode() {
    super.startDemoMode();
    for (var decorator in _decorators) {
      decorator.startDemoMode();
    }
  }

  @override
  void stopDemoMode() {
    for (var decorator in _decorators) {
      decorator.stopDemoMode();
    }
    super.stopDemoMode();
  }
}
