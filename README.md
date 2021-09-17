# tiny_locator

[![pub package](https://img.shields.io/pub/v/tiny_locator.svg)](https://pub.dartlang.org/packages/tiny_locator)


**[English](https://github.com/zuvola/tiny_locator/blob/master/README.md), [日本語](https://github.com/zuvola/tiny_locator/blob/master/README_jp.md)**


Tiny service locator that provides a global access point to services.

It is a very small library with less than 100 lines (without comments), making it easy for anyone to understand how it works. In addition, it has all the necessary functions.


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

