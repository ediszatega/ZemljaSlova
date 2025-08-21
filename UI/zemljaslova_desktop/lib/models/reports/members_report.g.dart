// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'members_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembersReport _$MembersReportFromJson(Map<String, dynamic> json) =>
    MembersReport(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalActiveMembers: (json['totalActiveMembers'] as num).toInt(),
      newMembersInPeriod: (json['newMembersInPeriod'] as num).toInt(),
      expiredMemberships: (json['expiredMemberships'] as num).toInt(),
      totalMemberships: (json['totalMemberships'] as num).toInt(),
      reportPeriod: json['reportPeriod'] as String,
      memberSummaries:
          (json['memberSummaries'] as List<dynamic>)
              .map((e) => MemberSummary.fromJson(e as Map<String, dynamic>))
              .toList(),
      membershipActivities:
          (json['membershipActivities'] as List<dynamic>)
              .map(
                (e) => MembershipActivity.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$MembersReportToJson(MembersReport instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalActiveMembers': instance.totalActiveMembers,
      'newMembersInPeriod': instance.newMembersInPeriod,
      'expiredMemberships': instance.expiredMemberships,
      'totalMemberships': instance.totalMemberships,
      'reportPeriod': instance.reportPeriod,
      'memberSummaries': instance.memberSummaries,
      'membershipActivities': instance.membershipActivities,
    };

MemberSummary _$MemberSummaryFromJson(Map<String, dynamic> json) =>
    MemberSummary(
      memberId: (json['memberId'] as num).toInt(),
      memberName: json['memberName'] as String,
      email: json['email'] as String,
      membershipStartDate:
          json['membershipStartDate'] == null
              ? null
              : DateTime.parse(json['membershipStartDate'] as String),
      membershipEndDate:
          json['membershipEndDate'] == null
              ? null
              : DateTime.parse(json['membershipEndDate'] as String),
      isActive: json['isActive'] as bool,
      totalRentals: (json['totalRentals'] as num).toInt(),
      totalPurchases: (json['totalPurchases'] as num).toInt(),
    );

Map<String, dynamic> _$MemberSummaryToJson(MemberSummary instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'memberName': instance.memberName,
      'email': instance.email,
      'membershipStartDate': instance.membershipStartDate?.toIso8601String(),
      'membershipEndDate': instance.membershipEndDate?.toIso8601String(),
      'isActive': instance.isActive,
      'totalRentals': instance.totalRentals,
      'totalPurchases': instance.totalPurchases,
    };

MembershipActivity _$MembershipActivityFromJson(Map<String, dynamic> json) =>
    MembershipActivity(
      id: (json['id'] as num).toInt(),
      memberName: json['memberName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$MembershipActivityToJson(MembershipActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberName': instance.memberName,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'status': instance.status,
    };
