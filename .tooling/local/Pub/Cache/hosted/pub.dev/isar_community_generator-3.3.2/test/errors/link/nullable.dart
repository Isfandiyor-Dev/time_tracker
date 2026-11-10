// must not be nullable

import 'package:isar_community/isar.dart';

@collection
class Model {
  Id? id;

  IsarLink<Model2>? link;
}

@collection
class Model2 {
  Id? id;
}
