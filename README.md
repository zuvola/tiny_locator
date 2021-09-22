# tiny_locator

[![pub package](https://img.shields.io/pub/v/tiny_locator.svg)](https://pub.dartlang.org/packages/tiny_locator)


**[English](https://github.com/zuvola/tiny_locator/blob/master/README.md), [日本語](https://github.com/zuvola/tiny_locator/blob/master/README_jp.md)**

Tiny service locator that provides a global access point to services.  
It can be combined with [tiny_react](https://pub.dartlang.org/packages/tiny_react) to make a tiny state management library in Flutter.

It is a very small library with less than 100 lines (without comments), so it is easy for anyone to understand how it works.


## Features

- Lookup services
- Hierarchical scopes

As the name suggests, smallness is our selling point, so we don't plan to add major features in the future, but we may add features that require only small fixes.


## Getting started

The simplest way to use it is as follows.

```dart
import 'package:tiny_locator/tiny_locator.dart';
void main() {
  // register
  locator.add(() => 'abc');
  // lookup
  print(locator.get<String>());
}
```
The ServiceLocator class is a singleton, and the object is assigned to the global variable `locator` in advance.


## Usage

### Register with singleton

Creates and registers the only object immediately.
Retrieving it with `get` will return the same object.

```dart
locator.add(() => Controller());
```

### Register as delayed creation

The object will be created at the time of acquisition with `get`. After that, the same object will be retrieved.

```dart
locator.add(() => Controller(), lazy: true);
```

### Register as created every time

A new object will be created each time it is retrieved with `get`.

```dart
locator.add(() => Controller(), singleton: false);
```

### Register as tagged

If you register the same class, it will be overwritten. If you want to register it as a different one, add `tag`.

```dart
locator.add(() => Controller(), tag: 'abc');
```

### Lookup

The service is retrieved by specifying the type and `tag`. If the service is not registered, an exception will be raised.
You can also use `contains` to get whether a service is registered or not.

```dart
if (locator.contains<Controller>()) {
  locator.get<Controller>();
}
if (locator.contains<Controller>(tag: 'abc')) {
  locator.get<Controller>(tag: 'abc');
}
```


### Remove

It can also be deleted as well as `get`.

```dart
if (locator.remove<Controller>()) {
  print('deleted');
};
locator.remove<Controller>(tag: 'abc');
```

### Scope

The `ServiceLocator` class retains the `ServiceContainer`, an implementation of the ServiceLocator, in a hierarchical structure.  
You can use `pop` and `push` to add and remove `ServiceContainer` from the hierarchy and use it as a scope.  
It is mainly intended to be used with Flutter's Navigator.

```dart
// register in the root scope
locator.add(() => ClassA());
// create a new scope
locator.push();
// register in a new scope
locator.add(() => ClassB());
// you can find both ClassA and ClassB
locator.get<ClassA>();
locator.get<ClassB>();
// destroy the current scope
locator.pop();
// now, you can find only ClassA
locator.get<ClassA>();
locator.get<ClassB>(); // Exception!
```


## tiny_react

[tiny_react](https://pub.dartlang.org/packages/tiny_react) is a syntax sugar to `ValueNotifier` and `ValueListenableBuilder`.  
When combined with `tiny_locator`, it becomes Flutter's tiny state management method.


```dart
import 'package:flutter/material.dart';
import 'package:tiny_locator/tiny_locator.dart';
import 'package:tiny_react/tiny_react.dart';

class MyController {
  final num = 0.notif;
  final list = <int>[].notif;

  void doSomething() {
    num.value++;
    if (num.value % 2 == 0) {
      list
        ..value.add(num.value)
        ..notifyListeners();
    }
  }
}

void main() {
  locator.add(() => MyController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyPage(),
    );
  }
}

class MyPage extends StatelessWidget {
  final controller = locator.get<MyController>();

  MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MyPage')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            controller.num.build((val) => Text('$val')),
            controller.list.build((val) => Text('$val')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.doSomething(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```
