// list<double> may must not be hashed

import 'package:isar_community/isar.dart';

@collection
class Model {
  Id? id;

  @Index(type: IndexType.hash)
  List<double>? list;
}
