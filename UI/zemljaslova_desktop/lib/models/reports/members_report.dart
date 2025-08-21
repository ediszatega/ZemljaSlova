import 'package:json_annotation/json_annotation.dart';

part 'members_report.g.dart';

@JsonSerializable()
class MembersReport {
  @JsonKey(name: 'startDate')
  final DateTime startDate;
  
  @JsonKey(name: 'endDate')
  final DateTime endDate;
  
  @JsonKey(name: 'totalActiveMembers')
  final int totalActiveMembers;
  
  @JsonKey(name: 'newMembersInPeriod')
  final int newMembersInPeriod;
  
  @JsonKey(name: 'expiredMemberships')
  final int expiredMemberships;
  
  @JsonKey(name: 'totalMemberships')
  final int totalMemberships;
  
  @JsonKey(name: 'reportPeriod')
  final String reportPeriod;
  
  @JsonKey(name: 'memberSummaries')
  final List<MemberSummary> memberSummaries;
  
  @JsonKey(name: 'membershipActivities')
  final List<MembershipActivity> membershipActivities;

  MembersReport({
    required this.startDate,
    required this.endDate,
    required this.totalActiveMembers,
    required this.newMembersInPeriod,
    required this.expiredMemberships,
    required this.totalMemberships,
    required this.reportPeriod,
    required this.memberSummaries,
    required this.membershipActivities,
  });

  factory MembersReport.fromJson(Map<String, dynamic> json) => _$MembersReportFromJson(json);
  Map<String, dynamic> toJson() => _$MembersReportToJson(this);
}

@JsonSerializable()
class MemberSummary {
  @JsonKey(name: 'memberId')
  final int memberId;
  
  @JsonKey(name: 'memberName')
  final String memberName;
  
  @JsonKey(name: 'email')
  final String email;
  
  @JsonKey(name: 'membershipStartDate')
  final DateTime? membershipStartDate;
  
  @JsonKey(name: 'membershipEndDate')
  final DateTime? membershipEndDate;
  
  @JsonKey(name: 'isActive')
  final bool isActive;
  
  @JsonKey(name: 'totalRentals')
  final int totalRentals;
  
  @JsonKey(name: 'totalPurchases')
  final int totalPurchases;

  MemberSummary({
    required this.memberId,
    required this.memberName,
    required this.email,
    this.membershipStartDate,
    this.membershipEndDate,
    required this.isActive,
    required this.totalRentals,
    required this.totalPurchases,
  });

  factory MemberSummary.fromJson(Map<String, dynamic> json) => _$MemberSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$MemberSummaryToJson(this);
}

@JsonSerializable()
class MembershipActivity {
  final int id;
  
  @JsonKey(name: 'memberName')
  final String memberName;
  
  @JsonKey(name: 'startDate')
  final DateTime startDate;
  
  @JsonKey(name: 'endDate')
  final DateTime endDate;
  
  @JsonKey(name: 'status')
  final String status;

  MembershipActivity({
    required this.id,
    required this.memberName,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory MembershipActivity.fromJson(Map<String, dynamic> json) => _$MembershipActivityFromJson(json);
  Map<String, dynamic> toJson() => _$MembershipActivityToJson(this);
}
