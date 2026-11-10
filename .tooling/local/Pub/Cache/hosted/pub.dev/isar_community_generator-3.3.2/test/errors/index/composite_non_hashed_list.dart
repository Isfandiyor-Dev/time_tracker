// composite indexes do not support non-hashed lists

import 'package:isar_community/isar.dart';

@collection
class Model {
  Id? id;

  @Index(composite: [CompositeIndex('str')], type: IndexType.value)
  List<int>? list;

  String? str;
}
