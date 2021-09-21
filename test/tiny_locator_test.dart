import 'package:test/test.dart';

import 'package:tiny_locator/tiny_locator.dart';

class TestClass {
  static int created = 0;
  TestClass() {
    created++;
  }
}

class ClassA {}

class ClassB {}

void main() {
  setUp(() {
    TestClass.created = 0;
    locator.clear();
  });

  test('not found', () {
    locator.add(() => ClassA());
    locator.add(() => ClassB());
    Object? exception;
    try {
      locator.get<TestClass>();
    } catch (e) {
      exception = e;
    }
    expect(exception, isNotNull);
    expect(exception.toString(), 'Exception: TestClass is not registered');
  });

  test('with tag', () {
    locator.add(() => ClassA());
    locator.add(() => ClassB());
    locator.add(() => TestClass(), tag: 'abc');

    final obj1 = locator.get<TestClass>(tag: 'abc');
    expect(obj1 is TestClass, true);

    Object? exception;
    try {
      locator.get<TestClass>();
    } catch (e) {
      exception = e;
    }
    expect(exception, isNotNull);
    expect(exception.toString(), 'Exception: TestClass is not registered');

    exception = null;
    try {
      locator.get<TestClass>(tag: 'def');
    } catch (e) {
      exception = e;
    }
    expect(exception, isNotNull);
    expect(exception.toString(), 'Exception: TestClass#def is not registered');
  });

  test('singleton', () {
    locator.add(() => ClassA());
    locator.add(() => ClassB());
    locator.add(() => TestClass());
    expect(TestClass.created, 1);
    final obj1 = locator.get<TestClass>();
    expect(obj1 is TestClass, true);
    // call get twice
    final obj2 = locator.get<TestClass>();
    expect(TestClass.created, 1);
    expect(obj1, obj2);
    // more
    locator.get<TestClass>();
    expect(TestClass.created, 1);
  });

  test('lazy', () {
    locator.add(() => ClassA());
    locator.add(() => ClassB());
    locator.add(() => TestClass(), lazy: true);
    expect(TestClass.created, 0);
    final obj1 = locator.get<TestClass>();
    expect(obj1 is TestClass, true);
    // call get twice
    final obj2 = locator.get<TestClass>();
    expect(TestClass.created, 1);
    expect(obj1 == obj2, true);
    // more
    locator.get<TestClass>();
    expect(TestClass.created, 1);
  });

  test('create every time', () {
    locator.add(() => ClassA());
    locator.add(() => ClassB());
    locator.add(() => TestClass(), singleton: false);
    expect(TestClass.created, 0);
    final obj1 = locator.get<TestClass>();
    expect(TestClass.created, 1);
    expect(obj1 is TestClass, true);
    // call get twice
    final obj2 = locator.get<TestClass>();
    expect(TestClass.created, 2);
    expect(obj1 == obj2, false);
    // more
    locator.get<TestClass>();
    expect(TestClass.created, 3);
    locator.get<TestClass>();
    expect(TestClass.created, 4);
  });

  test('contains', () {
    locator.add(() => ClassA());
    locator.add(() => ClassB(), lazy: true);
    expect(locator.contains<ClassA>(), true);
    expect(locator.contains<ClassB>(), true);
    expect(locator.contains<TestClass>(), false);
  });

  test('remove', () {
    locator.add(() => ClassA());
    locator.add(() => ClassB(), lazy: true);
    var ret = locator.remove<ClassA>();
    expect(ret, true);
    ret = locator.remove<ClassB>();
    expect(ret, true);
    ret = locator.remove<TestClass>();
    expect(ret, false);
    Object? exception;
    try {
      locator.get<ClassA>();
    } catch (e) {
      exception = e;
    }
    expect(exception, isNotNull);
  });

  test('scope', () {
    locator.add(() => ClassA());
    locator.push();
    locator.add(() => ClassB());
    var ret = locator.contains<ClassA>();
    expect(ret, true);
    ret = locator.contains<ClassB>();
    expect(ret, true);
    var objA = locator.get<ClassA>();
    expect(objA is ClassA, true);
    final objB = locator.get<ClassB>();
    expect(objB is ClassB, true);

    locator.pop();
    ret = locator.contains<ClassA>();
    expect(ret, true);
    ret = locator.contains<ClassB>();
    expect(ret, false);
    objA = locator.get<ClassA>();
    expect(objA is ClassA, true);
    Object? exception;
    try {
      locator.get<ClassB>();
    } catch (e) {
      exception = e;
    }
    expect(exception, isNotNull);
  });

  test('named scope', () {
    locator.push(name: 'myScope');
    locator.add(() => TestClass());
    locator.push();
    locator.add(() => ClassA());
    locator.push();
    locator.add(() => ClassB());
    locator.popUntil('myScope');
    var ret = locator.contains<ClassA>();
    expect(ret, false);
    ret = locator.contains<ClassB>();
    expect(ret, false);
    ret = locator.contains<TestClass>();
    expect(ret, true);
  });
}
