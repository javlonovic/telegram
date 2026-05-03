import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/contacts_datasource.dart';
import '../../domain/entities/contact_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

final contactsDataSourceProvider = Provider((_) => ContactsDataSource());

// ---------------------------------------------------------------------------
// Contacts list
// ---------------------------------------------------------------------------

final contactsProvider =
    StateNotifierProvider<ContactsNotifier, AsyncValue<List<ContactEntity>>>((ref) {
  return ContactsNotifier(ref.read(contactsDataSourceProvider));
});

class ContactsNotifier extends StateNotifier<AsyncValue<List<ContactEntity>>> {
  ContactsNotifier(this._ds) : super(const AsyncValue.loading()) {
    load();
  }

  final ContactsDataSource _ds;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _ds.getContacts());
  }

  Future<void> addContact(int userId, {String nickname = ''}) async {
    final contact = await _ds.addContact(userId, nickname: nickname);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([...current, contact]);
  }

  Future<void> removeContact(int contactId) async {
    await _ds.removeContact(contactId);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.where((c) => c.id != contactId).toList());
  }
}

// ---------------------------------------------------------------------------
// User search
// ---------------------------------------------------------------------------

final userSearchProvider =
    StateNotifierProvider<UserSearchNotifier, AsyncValue<List<UserEntity>>>((ref) {
  return UserSearchNotifier(ref.read(contactsDataSourceProvider));
});

class UserSearchNotifier extends StateNotifier<AsyncValue<List<UserEntity>>> {
  UserSearchNotifier(this._ds) : super(const AsyncValue.data([]));

  final ContactsDataSource _ds;

  Future<void> search(String query) async {
    if (query.trim().length < 2) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _ds.searchUsers(query));
  }

  void clear() => state = const AsyncValue.data([]);
}
