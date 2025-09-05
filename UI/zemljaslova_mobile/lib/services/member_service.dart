import '../models/member.dart';
import 'api_service.dart';

class MemberService {
  final ApiService _apiService;

  MemberService({required ApiService apiService}) : _apiService = apiService;

  Future<Member?> createMember({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    String? gender,
  }) async {
    try {
      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'joinedAt': DateTime.now().toIso8601String(),
        'gender': gender,
      };
      
      final response = await _apiService.post('Member/CreateMember', data);
      
      return _mapMemberFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom kreiranja člana.');
    }
  }

  Future<Member?> getMember(int id) async {
    try {
      final response = await _apiService.get('Member/$id');
      
      return _mapMemberFromBackend(response);
    } catch (e) {
      throw Exception('Član nije pronađen.');
    }
  }

  Future<Member?> getMemberByUserId(int userId) async {
    try {
      final response = await _apiService.get('Member/GetMemberByUserId/$userId');
      
      return _mapMemberFromBackend(response);
    } catch (e) {
      throw Exception('Član nije pronađen.');
    }
  }

  Future<Member?> updateMember({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    required DateTime dateOfBirth,
    String? gender,
  }) async {
    try {
      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': gender,
      };
      
      final response = await _apiService.put('Member/UpdateMember/$id', data);
      
      return _mapMemberFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom ažuriranja člana.');
    }
  }

  Member _mapMemberFromBackend(dynamic memberData) {
    // Extract member specific data
    int userId = memberData['userId'] ?? 0;
    String? profileImageUrl;
    
    // Check if user has an image
    dynamic imageData = memberData['user']?['image'] ?? memberData['profileImage'];
    
    if (imageData != null) {
      // Get the user ID to create the image URL
      if (userId > 0) {
        profileImageUrl = '${ApiService.baseUrl}/User/$userId/image';
      }
    }
    
    // Parse dates
    DateTime dateOfBirth = DateTime.now();
    if (memberData['dateOfBirth'] != null) {
      try {
        dateOfBirth = DateTime.parse(memberData['dateOfBirth']);
      } catch (e) {
        throw Exception('Greška prilikom parsiranja datuma rođenja.');
      }
    }
    
    DateTime joinedAt = DateTime.now();
    if (memberData['joinedAt'] != null) {
      try {
        joinedAt = DateTime.parse(memberData['joinedAt']);
      } catch (e) {
        throw Exception('Greška prilikom parsiranja datuma prijave.');
      }
    }
    
    // Extract user data from nested user object
    String firstName = '';
    String lastName = '';
    String email = '';
    String? gender;
    bool isActive = true;
    
    if (memberData['user'] is Map) {
      Map<String, dynamic> userData = memberData['user'];
      firstName = userData['firstName'] ?? '';
      lastName = userData['lastName'] ?? '';
      email = userData['email'] ?? '';
      gender = userData['gender'];
      isActive = userData['isActive'] ?? true;
    }

    return Member(
      id: memberData['id'] ?? 0,
      userId: userId,
      dateOfBirth: dateOfBirth,
      joinedAt: joinedAt,
      firstName: firstName,
      lastName: lastName,
      email: email,
      gender: gender,
      isActive: isActive,
      profileImageUrl: profileImageUrl,
    );
  }
} 