// Copyright 2021 zuvola. All rights reserved.

library tiny_locator;

/// Instance of ServiceLocator for easy access.
final locator = ServiceLocator();

/// Tiny service locator that provides a global access point to services
class ServiceLocator {
  /// Singleton instance of ServiceLocator
  factory ServiceLocator() => _instance ??= ServiceLocator._();
  static ServiceLocator? _instance;
  ServiceLocator._();

  /// Name of the root scope
  static final rootName = 'root';

  /// Currently active scope (ServiceContainer).
  ServiceContainer current = ServiceContainer(name: rootName);

  /// Clear all scopes
  void clear() {
    current = ServiceContainer(name: rootName);
  }

  /// Create a new scope and put it at the end of the stack
  void push({String? name}) {
    current = ServiceContainer(name: name, parent: current);
  }

  /// Remove the current scope and remove it from the stack
  void pop() {
    final parent = current.parent;
    if (parent != null) {
      current = parent;
    }
  }

  /// Call [pop] repeatedly until the name of the current scope is the same as [name].
  void popUntil(String name) {
    while (current.name != name && current.name != rootName) {
      pop();
    }
  }

  /// Register a service in the current scope
  void add<T>(T Function() factory,
      {String? tag, bool lazy = false, bool singleton = true}) {
    current.add<T>(factory, tag: tag, lazy: lazy, singleton: singleton);
  }

  /// Lookup a service in the current scope
  T get<T>({String? tag}) {
    return current.get<T>(tag: tag);
  }

  /// Remove a service in the current scope
  bool remove<T>({String? tag}) {
    return current.remove<T>(tag: tag);
  }

  /// Whether this container contains the service
  bool contains<T>({String? tag}) {
    return current.contains<T>(tag: tag);
  }
}

/// Implementation of the service locator pattern.
class ServiceContainer {
  final Map<String, _Service> _services = {};

  /// Name of the container (scope)
  final String? name;

  /// Parent of the container
  final ServiceContainer? parent;

  ServiceContainer({this.name, this.parent});

  /// Register a service
  void add<T>(T Function() factory,
      {String? tag, bool lazy = false, bool singleton = true}) {
    _services[_key(T, tag)] = _Service<T>(
      factory: factory,
      singleton: singleton,
      instance: !singleton || lazy ? null : factory(),
    );
  }

  /// Lookup a service from this container and its ancestors
  T get<T>({String? tag}) {
    final key = _key(T, tag);
    if (_services.containsKey(key)) {
      return _services[key]!.getInstance() as T;
    } else {
      if (parent != null) {
        return parent!.get<T>(tag: tag);
      }
      throw Exception('$key is not registered');
    }
  }

  /// Remove a service
  bool remove<T>({String? tag}) {
    return _services.remove(_key(T, tag)) != null;
  }

  /// Whether this container and its ancestors contain services
  bool contains<T>({String? tag}) {
    final result = _services.containsKey(_key(T, tag));
    if (!result && parent != null) {
      return parent!.contains<T>(tag: tag);
    }
    return result;
  }

  String _key<T>(T type, String? tag) {
    return tag == null ? '$type' : '$type#$tag';
  }
}

/// Internal class for storing services
class _Service<T> {
  final T Function() factory;
  final bool singleton;
  T? instance;

  _Service({required this.factory, this.instance, this.singleton = true});

  T getInstance() {
    if (!singleton) return factory();
    instance ??= factory();
    return instance!;
  }
}
