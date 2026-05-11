import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/contact_entity.dart';

class ContactsDataSource {
  ContactsDataSource() : _dio = DioClient.instance.dio;
  final Dio _dio;

  Future<List<ContactEntity>> getContacts() async {
    final response = await _dio.get(ApiConstants.contacts);
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      final results = data['results'] ?? data['contacts'] ?? data['data'] ?? [];
      list = results is List ? results : [];
    } else {
      list = [];
    }
    final parsed = <ContactEntity>[];
    for (final e in list) {
      if (e is Map<String, dynamic>) {
        try {
          parsed.add(_parseContact(e));
        } catch (_) {
          // skip malformed entries
        }
      }
    }
    return parsed;
  }

  Future<ContactEntity> addContact(int userId, {String nickname = ''}) async {
    final response = await _dio.post(
      ApiConstants.contacts,
      data: {'contact_id': userId, 'nickname': nickname},
    );
    return _parseContact(response.data as Map<String, dynamic>);
  }

  Future<void> removeContact(int contactId) async {
    await _dio.delete('${ApiConstants.contacts}$contactId/');
  }

  Future<List<UserEntity>> searchUsers(String query) async {
    final response = await _dio.get(
      ApiConstants.users,
      queryParameters: {'q': query},
    );
    // Handle: {"users": [...]}, {"results": [...]}, or plain list
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      list = (data['users'] ?? data['results'] ?? []) as List<dynamic>;
    } else {
      list = [];
    }
    return list
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  ContactEntity _parseContact(Map<String, dynamic> json) {
    // contact field is a nested UserSerializer object
    final contactRaw = json['contact'];
    if (contactRaw == null || contactRaw is! Map) {
      throw Exception('Invalid contact data: $json');
    }
    return ContactEntity(
      id: json['id'] as int,
      contact: UserModel.fromJson(contactRaw as Map<String, dynamic>).toEntity(),
      nickname: json['nickname'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
