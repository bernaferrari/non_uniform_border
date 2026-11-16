## 1.0.1

* Raise minimum Dart SDK to `^3.14.0` and Flutter SDK to `>=3.50.0`.
* Fix uniform `dimensions` inset calculation across `strokeAlign` values.
* Preserve `color`, `strokeAlign`, and scaled `borderRadius` in `scale()`.
* Update `getInnerPath()` to respect asymmetric side widths and `strokeAlign`.
* Remove redundant `_RRectInflation` extension (now provided by Flutter's `EdgeInsets`) and `library` declaration.
* Migrate example app to `package:material_ui/material_ui.dart` and update `flutter_lints` to `^6.0.0`.

## 1.0.0

* Initial release.
