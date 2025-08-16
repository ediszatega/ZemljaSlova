import 'package:json_annotation/json_annotation.dart';

part 'shipping_address.g.dart';

@JsonSerializable()
class ShippingAddress {
  final String firstName;
  final String lastName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String postalCode;
  final String country;
  final String phoneNumber;
  final String? email;

  ShippingAddress({
    required this.firstName,
    required this.lastName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.postalCode,
    required this.country,
    required this.phoneNumber,
    this.email,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) => _$ShippingAddressFromJson(json);
  Map<String, dynamic> toJson() => _$ShippingAddressToJson(this);

  String get fullName => '$firstName $lastName';
  String get fullAddress => [
    addressLine1,
    if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
    '$city, $postalCode',
    country,
  ].join(', ');
}
