// only strings and lists may be hashed

import 'package:isar_community/isar.dart';

@collection
class Model {
  Id? id;

  @Index(type: IndexType.hash)
  int? val;
}
