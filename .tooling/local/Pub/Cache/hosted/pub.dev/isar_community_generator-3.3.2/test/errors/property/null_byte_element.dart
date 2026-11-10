// bytes must not be nullable

import 'package:isar_community/isar.dart';

@collection
class Model {
  Id? id;

  late List<byte?> prop;
}
