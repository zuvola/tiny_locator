import 'package:tiny_locator/tiny_locator.dart';

void main() {
  // register
  locator.add(() => 'abc');
  // lookup
  print(locator.get<String>());
}
