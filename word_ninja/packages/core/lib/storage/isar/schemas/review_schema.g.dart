// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReviewSchemaCollection on Isar {
  IsarCollection<ReviewSchema> get reviewSchemas => this.collection();
}

const ReviewSchemaSchema = CollectionSchema(
  name: r'ReviewSchema',
  id: -3486998386088291512,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isCompleted': PropertySchema(
      id: 1,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'reviewId': PropertySchema(
      id: 2,
      name: r'reviewId',
      type: IsarType.string,
    ),
    r'reviewTime': PropertySchema(
      id: 3,
      name: r'reviewTime',
      type: IsarType.dateTime,
    ),
    r'score': PropertySchema(
      id: 4,
      name: r'score',
      type: IsarType.long,
    ),
    r'wordId': PropertySchema(
      id: 5,
      name: r'wordId',
      type: IsarType.string,
    )
  },
  estimateSize: _reviewSchemaEstimateSize,
  serialize: _reviewSchemaSerialize,
  deserialize: _reviewSchemaDeserialize,
  deserializeProp: _reviewSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'reviewId': IndexSchema(
      id: 392236526580651382,
      name: r'reviewId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'reviewId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _reviewSchemaGetId,
  getLinks: _reviewSchemaGetLinks,
  attach: _reviewSchemaAttach,
  version: '3.1.0+1',
);

int _reviewSchemaEstimateSize(
  ReviewSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.reviewId.length * 3;
  bytesCount += 3 + object.wordId.length * 3;
  return bytesCount;
}

void _reviewSchemaSerialize(
  ReviewSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.isCompleted);
  writer.writeString(offsets[2], object.reviewId);
  writer.writeDateTime(offsets[3], object.reviewTime);
  writer.writeLong(offsets[4], object.score);
  writer.writeString(offsets[5], object.wordId);
}

ReviewSchema _reviewSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReviewSchema();
  object.createdAt = reader.readDateTimeOrNull(offsets[0]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[1]);
  object.reviewId = reader.readString(offsets[2]);
  object.reviewTime = reader.readDateTime(offsets[3]);
  object.score = reader.readLong(offsets[4]);
  object.wordId = reader.readString(offsets[5]);
  return object;
}

P _reviewSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _reviewSchemaGetId(ReviewSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _reviewSchemaGetLinks(ReviewSchema object) {
  return [];
}

void _reviewSchemaAttach(
    IsarCollection<dynamic> col, Id id, ReviewSchema object) {
  object.id = id;
}

extension ReviewSchemaQueryWhereSort
    on QueryBuilder<ReviewSchema, ReviewSchema, QWhere> {
  QueryBuilder<ReviewSchema, ReviewSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReviewSchemaQueryWhere
    on QueryBuilder<ReviewSchema, ReviewSchema, QWhereClause> {
  QueryBuilder<ReviewSchema, ReviewSchema, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterWhereClause> reviewIdEqualTo(
      String reviewId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'reviewId',
        value: [reviewId],
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterWhereClause>
      reviewIdNotEqualTo(String reviewId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reviewId',
              lower: [],
              upper: [reviewId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reviewId',
              lower: [reviewId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reviewId',
              lower: [reviewId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reviewId',
              lower: [],
              upper: [reviewId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ReviewSchemaQueryFilter
    on QueryBuilder<ReviewSchema, ReviewSchema, QFilterCondition> {
  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      reviewIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      reviewIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      reviewIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      reviewIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      reviewIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reviewId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      reviewIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reviewId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      reviewIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reviewId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      reviewIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reviewId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      reviewIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      reviewIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reviewId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      reviewTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      reviewTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      reviewTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      reviewTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition> scoreEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      scoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition> scoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition> scoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'score',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition> wordIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      wordIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      wordIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition> wordIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wordId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      wordIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'wordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      wordIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'wordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      wordIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'wordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition> wordIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'wordId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      wordIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wordId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterFilterCondition>
      wordIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'wordId',
        value: '',
      ));
    });
  }
}

extension ReviewSchemaQueryObject
    on QueryBuilder<ReviewSchema, ReviewSchema, QFilterCondition> {}

extension ReviewSchemaQueryLinks
    on QueryBuilder<ReviewSchema, ReviewSchema, QFilterCondition> {}

extension ReviewSchemaQuerySortBy
    on QueryBuilder<ReviewSchema, ReviewSchema, QSortBy> {
  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy>
      sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> sortByReviewId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewId', Sort.asc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> sortByReviewIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewId', Sort.desc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> sortByReviewTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewTime', Sort.asc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy>
      sortByReviewTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewTime', Sort.desc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> sortByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> sortByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> sortByWordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordId', Sort.asc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> sortByWordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordId', Sort.desc);
    });
  }
}

extension ReviewSchemaQuerySortThenBy
    on QueryBuilder<ReviewSchema, ReviewSchema, QSortThenBy> {
  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy>
      thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> thenByReviewId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewId', Sort.asc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> thenByReviewIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewId', Sort.desc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> thenByReviewTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewTime', Sort.asc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy>
      thenByReviewTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewTime', Sort.desc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> thenByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> thenByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> thenByWordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordId', Sort.asc);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QAfterSortBy> thenByWordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordId', Sort.desc);
    });
  }
}

extension ReviewSchemaQueryWhereDistinct
    on QueryBuilder<ReviewSchema, ReviewSchema, QDistinct> {
  QueryBuilder<ReviewSchema, ReviewSchema, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QDistinct> distinctByReviewId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QDistinct> distinctByReviewTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewTime');
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QDistinct> distinctByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'score');
    });
  }

  QueryBuilder<ReviewSchema, ReviewSchema, QDistinct> distinctByWordId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wordId', caseSensitive: caseSensitive);
    });
  }
}

extension ReviewSchemaQueryProperty
    on QueryBuilder<ReviewSchema, ReviewSchema, QQueryProperty> {
  QueryBuilder<ReviewSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReviewSchema, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ReviewSchema, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<ReviewSchema, String, QQueryOperations> reviewIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewId');
    });
  }

  QueryBuilder<ReviewSchema, DateTime, QQueryOperations> reviewTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewTime');
    });
  }

  QueryBuilder<ReviewSchema, int, QQueryOperations> scoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'score');
    });
  }

  QueryBuilder<ReviewSchema, String, QQueryOperations> wordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wordId');
    });
  }
}
