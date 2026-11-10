// only unique indexes can replace

import 'package:isar_community/isar.dart';

@collection
class Model {
  Id? id;

  @Index(replace: true)
  String? str;
}
