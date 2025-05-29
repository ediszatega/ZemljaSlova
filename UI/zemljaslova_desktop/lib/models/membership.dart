import 'package:json_annotation/json_annotation.dart';
import 'member.dart';

part 'membership.g.dart';

@JsonSerializable()
class Membership {
  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final int memberId;
  final Member? member;

  Membership({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.memberId,
    this.member,
  });

  factory Membership.fromJson(Map<String, dynamic> json) => _$MembershipFromJson(json);

  Map<String, dynamic> toJson() => _$MembershipToJson(this);

  // Helper getters
  bool get isActive {
    final now = DateTime.now();
    return startDate.isBefore(now.add(const Duration(days: 1))) && 
           endDate.isAfter(now.subtract(const Duration(days: 1)));
  }

  bool get isExpired {
    final now = DateTime.now();
    return endDate.isBefore(now);
  }

  String get statusDisplay {
    if (isExpired) return 'Istekla';
    if (isActive) return 'Aktivna';
    return 'Neaktivna';
  }

  String get memberDisplay {
    if (member != null) {
      return member!.fullName;
    }
    return 'Član ID: $memberId';
  }

  int get daysRemaining {
    if (isExpired) return 0;
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }
} 