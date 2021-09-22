# tiny_locator

[![pub package](https://img.shields.io/pub/v/tiny_locator.svg)](https://pub.dartlang.org/packages/tiny_locator)


**[English](https://github.com/zuvola/tiny_locator/blob/master/README.md), [日本語](https://github.com/zuvola/tiny_locator/blob/master/README_jp.md)**


`tiny_locator`はサービス(オブジェクト)へのグローバルなアクセスポイントとなる小さなサービスロケータです。  
[tiny_react](https://pub.dartlang.org/packages/tiny_react)
と組み合わせる事で極小の状態管理ライブラリとなります。

100行未満(コメント抜き)のとても小さなライブラリなので誰でも動きの把握がしやすくなっています。


## Features

- サービスの取得
- 階層化されたスコープ

名前の通り小ささが売りなので今後も大きな機能追加をするつもりはありませんが、小さな修正で済む機能追加などは行うかもしれません。


## Getting started

一番簡単な使い方は下記のようになります。

```dart
import 'package:tiny_locator/tiny_locator.dart';

void main() {
  // 登録
  locator.add(() => 'abc');
  // 取得
  print(locator.get<String>());
}
```
`ServiceLocator`クラスはシングルトンになっておりあらかじめグローバル変数のlocatorにオブジェクトが代入されています。


## Usage

### シングルトンとして登録

唯一のオブジェクトを直ちに作成して登録します。  
`get`で取得すると同じオブジェクトが返されます。

```dart
locator.add(() => Controller());
```

### 遅延作成として登録

`get`で取得するタイミングでオブジェクトが生成されます。以後取得されるのは同じオブジェクトになります。

```dart
locator.add(() => Controller(), lazy: true);
```

### 都度作成として登録

`get`で取得される度に新しいオブジェクトが生成されます。

```dart
locator.add(() => Controller(), singleton: false);
```

### タグを付けて登録

同一クラスを登録する場合は上書きになってしまいます。別なものとして登録したい場合は`tag`を付加してください。

```dart
locator.add(() => Controller(), tag: 'abc');
```

### 取得

サービスの取得は型と`tag`の指定で行います。サービスが登録されていない場合は例外が発生します。  
サービスが登録済みかを`contains`で取得することも出来ます。

```dart
if (locator.contains<Controller>()) {
  locator.get<Controller>();
}
if (locator.contains<Controller>(tag: 'abc')) {
  locator.get<Controller>(tag: 'abc');
}
```

### 削除

`get`と同様に削除も可能です。

```dart
if (locator.remove<Controller>()) {
  print('deleted');
};
locator.remove<Controller>(tag: 'abc');
```

### スコープ

`ServiceLocator`クラスはServiceLocatorの実装である`ServiceContainer`を階層構造で保持しています。
`pop`と`push`で`ServiceContainer`を階層に追加・削除することができ、これをスコープとして利用することが出来ます。
主にFlutterのNavigatorで使用する事を想定しています。

```dart
// ルートスコープへ追加
locator.add(() => ClassA());
// 新しいスコープを作成
locator.push();
// 新しいスコープに追加
locator.add(() => ClassB());
// ClassAとClassBの両方を取得できる
locator.get<ClassA>();
locator.get<ClassB>();
// 現在のスコープを破棄
locator.pop();
// ClassBも破棄され取得できなくなる
locator.get<ClassA>();
locator.get<ClassB>(); // Exception!
```


## tiny_react

`tiny_react`は`ValueNotifier`と`ValueListenableBuilder`へのシンタックスシュガーです。  
tiny_locatorと組み合わせることでFlutterの極小の状態管理手法になります。

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
