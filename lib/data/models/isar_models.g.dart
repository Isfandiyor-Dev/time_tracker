// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProjectRecordCollection on Isar {
  IsarCollection<ProjectRecord> get projectRecords => this.collection();
}

const ProjectRecordSchema = CollectionSchema(
  name: r'ProjectRecord',
  id: -8086432811155279315,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currency': PropertySchema(
      id: 1,
      name: r'currency',
      type: IsarType.string,
    ),
    r'hourlyRate': PropertySchema(
      id: 2,
      name: r'hourlyRate',
      type: IsarType.double,
    ),
    r'name': PropertySchema(id: 3, name: r'name', type: IsarType.string),
  },

  estimateSize: _projectRecordEstimateSize,
  serialize: _projectRecordSerialize,
  deserialize: _projectRecordDeserialize,
  deserializeProp: _projectRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _projectRecordGetId,
  getLinks: _projectRecordGetLinks,
  attach: _projectRecordAttach,
  version: '3.3.2',
);

int _projectRecordEstimateSize(
  ProjectRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _projectRecordSerialize(
  ProjectRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.currency);
  writer.writeDouble(offsets[2], object.hourlyRate);
  writer.writeString(offsets[3], object.name);
}

ProjectRecord _projectRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProjectRecord();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.currency = reader.readString(offsets[1]);
  object.hourlyRate = reader.readDouble(offsets[2]);
  object.id = id;
  object.name = reader.readString(offsets[3]);
  return object;
}

P _projectRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _projectRecordGetId(ProjectRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _projectRecordGetLinks(ProjectRecord object) {
  return [];
}

void _projectRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  ProjectRecord object,
) {
  object.id = id;
}

extension ProjectRecordQueryWhereSort
    on QueryBuilder<ProjectRecord, ProjectRecord, QWhere> {
  QueryBuilder<ProjectRecord, ProjectRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProjectRecordQueryWhere
    on QueryBuilder<ProjectRecord, ProjectRecord, QWhereClause> {
  QueryBuilder<ProjectRecord, ProjectRecord, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ProjectRecordQueryFilter
    on QueryBuilder<ProjectRecord, ProjectRecord, QFilterCondition> {
  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  currencyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  currencyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  currencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  currencyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currency',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  currencyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  currencyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currency',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currency', value: ''),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currency', value: ''),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  hourlyRateEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hourlyRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  hourlyRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hourlyRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  hourlyRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hourlyRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  hourlyRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hourlyRate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }
}

extension ProjectRecordQueryObject
    on QueryBuilder<ProjectRecord, ProjectRecord, QFilterCondition> {}

extension ProjectRecordQueryLinks
    on QueryBuilder<ProjectRecord, ProjectRecord, QFilterCondition> {}

extension ProjectRecordQuerySortBy
    on QueryBuilder<ProjectRecord, ProjectRecord, QSortBy> {
  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy>
  sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy> sortByHourlyRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourlyRate', Sort.asc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy>
  sortByHourlyRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourlyRate', Sort.desc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension ProjectRecordQuerySortThenBy
    on QueryBuilder<ProjectRecord, ProjectRecord, QSortThenBy> {
  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy>
  thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy> thenByHourlyRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourlyRate', Sort.asc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy>
  thenByHourlyRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourlyRate', Sort.desc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension ProjectRecordQueryWhereDistinct
    on QueryBuilder<ProjectRecord, ProjectRecord, QDistinct> {
  QueryBuilder<ProjectRecord, ProjectRecord, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QDistinct> distinctByCurrency({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QDistinct> distinctByHourlyRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hourlyRate');
    });
  }

  QueryBuilder<ProjectRecord, ProjectRecord, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension ProjectRecordQueryProperty
    on QueryBuilder<ProjectRecord, ProjectRecord, QQueryProperty> {
  QueryBuilder<ProjectRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProjectRecord, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ProjectRecord, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<ProjectRecord, double, QQueryOperations> hourlyRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hourlyRate');
    });
  }

  QueryBuilder<ProjectRecord, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTimeEntryRecordCollection on Isar {
  IsarCollection<TimeEntryRecord> get timeEntryRecords => this.collection();
}

const TimeEntryRecordSchema = CollectionSchema(
  name: r'TimeEntryRecord',
  id: 7305803013740032726,
  properties: {
    r'breaks': PropertySchema(
      id: 0,
      name: r'breaks',
      type: IsarType.objectList,

      target: r'BreakRecord',
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currencySnapshot': PropertySchema(
      id: 2,
      name: r'currencySnapshot',
      type: IsarType.string,
    ),
    r'end': PropertySchema(id: 3, name: r'end', type: IsarType.dateTime),
    r'hourlyRateSnapshot': PropertySchema(
      id: 4,
      name: r'hourlyRateSnapshot',
      type: IsarType.double,
    ),
    r'isPaid': PropertySchema(id: 5, name: r'isPaid', type: IsarType.bool),
    r'notes': PropertySchema(id: 6, name: r'notes', type: IsarType.string),
    r'projectId': PropertySchema(
      id: 7,
      name: r'projectId',
      type: IsarType.long,
    ),
    r'start': PropertySchema(id: 8, name: r'start', type: IsarType.dateTime),
  },

  estimateSize: _timeEntryRecordEstimateSize,
  serialize: _timeEntryRecordSerialize,
  deserialize: _timeEntryRecordDeserialize,
  deserializeProp: _timeEntryRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'projectId': IndexSchema(
      id: 3305656282123791113,
      name: r'projectId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'projectId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'start': IndexSchema(
      id: -5775659401471708833,
      name: r'start',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'start',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'isPaid': IndexSchema(
      id: -8955270508682588844,
      name: r'isPaid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isPaid',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'BreakRecord': BreakRecordSchema},

  getId: _timeEntryRecordGetId,
  getLinks: _timeEntryRecordGetLinks,
  attach: _timeEntryRecordAttach,
  version: '3.3.2',
);

int _timeEntryRecordEstimateSize(
  TimeEntryRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.breaks.length * 3;
  {
    final offsets = allOffsets[BreakRecord]!;
    for (var i = 0; i < object.breaks.length; i++) {
      final value = object.breaks[i];
      bytesCount += BreakRecordSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.currencySnapshot.length * 3;
  bytesCount += 3 + object.notes.length * 3;
  return bytesCount;
}

void _timeEntryRecordSerialize(
  TimeEntryRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<BreakRecord>(
    offsets[0],
    allOffsets,
    BreakRecordSchema.serialize,
    object.breaks,
  );
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.currencySnapshot);
  writer.writeDateTime(offsets[3], object.end);
  writer.writeDouble(offsets[4], object.hourlyRateSnapshot);
  writer.writeBool(offsets[5], object.isPaid);
  writer.writeString(offsets[6], object.notes);
  writer.writeLong(offsets[7], object.projectId);
  writer.writeDateTime(offsets[8], object.start);
}

TimeEntryRecord _timeEntryRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TimeEntryRecord();
  object.breaks =
      reader.readObjectList<BreakRecord>(
        offsets[0],
        BreakRecordSchema.deserialize,
        allOffsets,
        BreakRecord(),
      ) ??
      [];
  object.createdAt = reader.readDateTime(offsets[1]);
  object.currencySnapshot = reader.readString(offsets[2]);
  object.end = reader.readDateTime(offsets[3]);
  object.hourlyRateSnapshot = reader.readDouble(offsets[4]);
  object.id = id;
  object.isPaid = reader.readBool(offsets[5]);
  object.notes = reader.readString(offsets[6]);
  object.projectId = reader.readLong(offsets[7]);
  object.start = reader.readDateTime(offsets[8]);
  return object;
}

P _timeEntryRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<BreakRecord>(
                offset,
                BreakRecordSchema.deserialize,
                allOffsets,
                BreakRecord(),
              ) ??
              [])
          as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _timeEntryRecordGetId(TimeEntryRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _timeEntryRecordGetLinks(TimeEntryRecord object) {
  return [];
}

void _timeEntryRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  TimeEntryRecord object,
) {
  object.id = id;
}

extension TimeEntryRecordQueryWhereSort
    on QueryBuilder<TimeEntryRecord, TimeEntryRecord, QWhere> {
  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhere> anyProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'projectId'),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhere> anyStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'start'),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhere> anyIsPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isPaid'),
      );
    });
  }
}

extension TimeEntryRecordQueryWhere
    on QueryBuilder<TimeEntryRecord, TimeEntryRecord, QWhereClause> {
  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause>
  projectIdEqualTo(int projectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'projectId', value: [projectId]),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause>
  projectIdNotEqualTo(int projectId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'projectId',
                lower: [],
                upper: [projectId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'projectId',
                lower: [projectId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'projectId',
                lower: [projectId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'projectId',
                lower: [],
                upper: [projectId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause>
  projectIdGreaterThan(int projectId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'projectId',
          lower: [projectId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause>
  projectIdLessThan(int projectId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'projectId',
          lower: [],
          upper: [projectId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause>
  projectIdBetween(
    int lowerProjectId,
    int upperProjectId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'projectId',
          lower: [lowerProjectId],
          includeLower: includeLower,
          upper: [upperProjectId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause>
  startEqualTo(DateTime start) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'start', value: [start]),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause>
  startNotEqualTo(DateTime start) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'start',
                lower: [],
                upper: [start],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'start',
                lower: [start],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'start',
                lower: [start],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'start',
                lower: [],
                upper: [start],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause>
  startGreaterThan(DateTime start, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'start',
          lower: [start],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause>
  startLessThan(DateTime start, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'start',
          lower: [],
          upper: [start],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause>
  startBetween(
    DateTime lowerStart,
    DateTime upperStart, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'start',
          lower: [lowerStart],
          includeLower: includeLower,
          upper: [upperStart],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause>
  isPaidEqualTo(bool isPaid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'isPaid', value: [isPaid]),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterWhereClause>
  isPaidNotEqualTo(bool isPaid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isPaid',
                lower: [],
                upper: [isPaid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isPaid',
                lower: [isPaid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isPaid',
                lower: [isPaid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isPaid',
                lower: [],
                upper: [isPaid],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension TimeEntryRecordQueryFilter
    on QueryBuilder<TimeEntryRecord, TimeEntryRecord, QFilterCondition> {
  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  breaksLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'breaks', length, true, length, true);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  breaksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'breaks', 0, true, 0, true);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  breaksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'breaks', 0, false, 999999, true);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  breaksLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'breaks', 0, true, length, include);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  breaksLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'breaks', length, include, 999999, true);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  breaksLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'breaks',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  currencySnapshotEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currencySnapshot',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  currencySnapshotGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currencySnapshot',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  currencySnapshotLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currencySnapshot',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  currencySnapshotBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currencySnapshot',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  currencySnapshotStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currencySnapshot',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  currencySnapshotEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currencySnapshot',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  currencySnapshotContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currencySnapshot',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  currencySnapshotMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currencySnapshot',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  currencySnapshotIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currencySnapshot', value: ''),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  currencySnapshotIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currencySnapshot', value: ''),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  endEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'end', value: value),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  endGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'end',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  endLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'end',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  endBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'end',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  hourlyRateSnapshotEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hourlyRateSnapshot',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  hourlyRateSnapshotGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hourlyRateSnapshot',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  hourlyRateSnapshotLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hourlyRateSnapshot',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  hourlyRateSnapshotBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hourlyRateSnapshot',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  isPaidEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isPaid', value: value),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  notesEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  notesGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  notesLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  notesBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  notesStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  notesEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'notes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  projectIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'projectId', value: value),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  projectIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'projectId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  projectIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'projectId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  projectIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'projectId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  startEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'start', value: value),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  startGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'start',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  startLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'start',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  startBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'start',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TimeEntryRecordQueryObject
    on QueryBuilder<TimeEntryRecord, TimeEntryRecord, QFilterCondition> {
  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterFilterCondition>
  breaksElement(FilterQuery<BreakRecord> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'breaks');
    });
  }
}

extension TimeEntryRecordQueryLinks
    on QueryBuilder<TimeEntryRecord, TimeEntryRecord, QFilterCondition> {}

extension TimeEntryRecordQuerySortBy
    on QueryBuilder<TimeEntryRecord, TimeEntryRecord, QSortBy> {
  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  sortByCurrencySnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySnapshot', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  sortByCurrencySnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySnapshot', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy> sortByEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy> sortByEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  sortByHourlyRateSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourlyRateSnapshot', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  sortByHourlyRateSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourlyRateSnapshot', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy> sortByIsPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  sortByIsPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  sortByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  sortByProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy> sortByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  sortByStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.desc);
    });
  }
}

extension TimeEntryRecordQuerySortThenBy
    on QueryBuilder<TimeEntryRecord, TimeEntryRecord, QSortThenBy> {
  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  thenByCurrencySnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySnapshot', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  thenByCurrencySnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySnapshot', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy> thenByEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy> thenByEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  thenByHourlyRateSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourlyRateSnapshot', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  thenByHourlyRateSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourlyRateSnapshot', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy> thenByIsPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  thenByIsPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  thenByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  thenByProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.desc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy> thenByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.asc);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QAfterSortBy>
  thenByStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.desc);
    });
  }
}

extension TimeEntryRecordQueryWhereDistinct
    on QueryBuilder<TimeEntryRecord, TimeEntryRecord, QDistinct> {
  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QDistinct>
  distinctByCurrencySnapshot({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'currencySnapshot',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QDistinct> distinctByEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'end');
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QDistinct>
  distinctByHourlyRateSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hourlyRateSnapshot');
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QDistinct> distinctByIsPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPaid');
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QDistinct>
  distinctByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectId');
    });
  }

  QueryBuilder<TimeEntryRecord, TimeEntryRecord, QDistinct> distinctByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'start');
    });
  }
}

extension TimeEntryRecordQueryProperty
    on QueryBuilder<TimeEntryRecord, TimeEntryRecord, QQueryProperty> {
  QueryBuilder<TimeEntryRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TimeEntryRecord, List<BreakRecord>, QQueryOperations>
  breaksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'breaks');
    });
  }

  QueryBuilder<TimeEntryRecord, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TimeEntryRecord, String, QQueryOperations>
  currencySnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencySnapshot');
    });
  }

  QueryBuilder<TimeEntryRecord, DateTime, QQueryOperations> endProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'end');
    });
  }

  QueryBuilder<TimeEntryRecord, double, QQueryOperations>
  hourlyRateSnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hourlyRateSnapshot');
    });
  }

  QueryBuilder<TimeEntryRecord, bool, QQueryOperations> isPaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPaid');
    });
  }

  QueryBuilder<TimeEntryRecord, String, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<TimeEntryRecord, int, QQueryOperations> projectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectId');
    });
  }

  QueryBuilder<TimeEntryRecord, DateTime, QQueryOperations> startProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'start');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const BreakRecordSchema = Schema(
  name: r'BreakRecord',
  id: 3009742982702677282,
  properties: {
    r'end': PropertySchema(id: 0, name: r'end', type: IsarType.dateTime),
    r'start': PropertySchema(id: 1, name: r'start', type: IsarType.dateTime),
  },

  estimateSize: _breakRecordEstimateSize,
  serialize: _breakRecordSerialize,
  deserialize: _breakRecordDeserialize,
  deserializeProp: _breakRecordDeserializeProp,
);

int _breakRecordEstimateSize(
  BreakRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _breakRecordSerialize(
  BreakRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.end);
  writer.writeDateTime(offsets[1], object.start);
}

BreakRecord _breakRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BreakRecord();
  object.end = reader.readDateTimeOrNull(offsets[0]);
  object.start = reader.readDateTimeOrNull(offsets[1]);
  return object;
}

P _breakRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension BreakRecordQueryFilter
    on QueryBuilder<BreakRecord, BreakRecord, QFilterCondition> {
  QueryBuilder<BreakRecord, BreakRecord, QAfterFilterCondition> endIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'end'),
      );
    });
  }

  QueryBuilder<BreakRecord, BreakRecord, QAfterFilterCondition> endIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'end'),
      );
    });
  }

  QueryBuilder<BreakRecord, BreakRecord, QAfterFilterCondition> endEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'end', value: value),
      );
    });
  }

  QueryBuilder<BreakRecord, BreakRecord, QAfterFilterCondition> endGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'end',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BreakRecord, BreakRecord, QAfterFilterCondition> endLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'end',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BreakRecord, BreakRecord, QAfterFilterCondition> endBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'end',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BreakRecord, BreakRecord, QAfterFilterCondition> startIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'start'),
      );
    });
  }

  QueryBuilder<BreakRecord, BreakRecord, QAfterFilterCondition>
  startIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'start'),
      );
    });
  }

  QueryBuilder<BreakRecord, BreakRecord, QAfterFilterCondition> startEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'start', value: value),
      );
    });
  }

  QueryBuilder<BreakRecord, BreakRecord, QAfterFilterCondition>
  startGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'start',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BreakRecord, BreakRecord, QAfterFilterCondition> startLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'start',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BreakRecord, BreakRecord, QAfterFilterCondition> startBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'start',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension BreakRecordQueryObject
    on QueryBuilder<BreakRecord, BreakRecord, QFilterCondition> {}
