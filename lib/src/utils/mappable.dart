// mappable.dart

/// An interface to ensure classes can be converted to a Map.
abstract class Mappable {
  Map<String, dynamic> toMap();
}
