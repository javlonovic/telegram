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
    final list = response.data as List<dynamic>;
    return list.map((e) => _parseContact(e as Map<String, dynamic>)).toList();
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
    final list = response.data['users'] as List<dynamic>;
    return list
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  ContactEntity _parseContact(Map<String, dynamic> json) {
    return ContactEntity(
      id: json['id'] as int,
      contact: UserModel.fromJson(json['contact'] as Map<String, dynamic>).toEntity(),
      nickname: json['nickname'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
