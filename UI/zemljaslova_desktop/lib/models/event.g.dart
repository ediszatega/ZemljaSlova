// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String?,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      organizer: json['organizer'] as String?,
      lecturers: json['lecturers'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      maxNumberOfPeople: (json['maxNumberOfPeople'] as num?)?.toInt(),
      ticketTypes: (json['ticketTypes'] as List<dynamic>?)
          ?.map((e) => TicketType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'location': instance.location,
      'startAt': instance.startAt.toIso8601String(),
      'endAt': instance.endAt.toIso8601String(),
      'organizer': instance.organizer,
      'lecturers': instance.lecturers,
      'coverImageUrl': instance.coverImageUrl,
      'maxNumberOfPeople': instance.maxNumberOfPeople,
      'ticketTypes': instance.ticketTypes,
    };
