import 'package:json_annotation/json_annotation.dart';

part 'paged_result.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PagedResult<T> {
  final int count;
  final List<T> resultList;

  PagedResult({
    required this.count,
    required this.resultList,
  });

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PagedResultFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PagedResultToJson(this, toJsonT);
}
