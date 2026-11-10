// link target is not annotated with @collection

import 'package:isar_community/isar.dart';

@collection
class Model {
  Id? id;

  final IsarLink<int> link = IsarLink();
}
