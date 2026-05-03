import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../contacts/presentation/providers/contacts_provider.dart';

class NewGroupScreen extends ConsumerStatefulWidget {
  const NewGroupScreen({super.key});

  @override
  ConsumerState<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends ConsumerState<NewGroupScreen> {
  final _nameController = TextEditingController();
  final _selectedMembers = <UserEntity>{};
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group name is required.')),
      );
      return;
    }
    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one member.')),
      );
      return;
    }

    setState(() => _isCreating = true);
    try {
      final response = await DioClient.instance.dio.post(
        ApiConstants.chats,
        data: {
          'type': 'group',
          'group_name': _nameController.text.trim(),
          'member_ids': _selectedMembers.map((u) => u.id).toList(),
        },
      );
      final chatId = response.data['id'] as int;
      if (mounted) context.go('/chats/$chatId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Group')),
      body: Column(
        children: [
          // Group name input
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Group name',
                prefixIcon: Icon(Icons.group_outlined),
              ),
            ),
          ),

          // Selected members chips
          if (_selectedMembers.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: _selectedMembers.map((user) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            AppAvatar(name: user.username, size: 48),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _selectedMembers.remove(user)),
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(user.username,
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          const Divider(),

          // Contacts list
          Expanded(
            child: contactsAsync.when(
              data: (contacts) => ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final c = contacts[index];
                  final isSelected = _selectedMembers.contains(c.contact);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) => setState(() {
                      if (isSelected) {
                        _selectedMembers.remove(c.contact);
                      } else {
                        _selectedMembers.add(c.contact);
                      }
                    }),
                    secondary: AppAvatar(
                      name: c.displayName,
                      imageUrl: c.contact.avatarUrl,
                      size: 40,
                    ),
                    title: Text(c.displayName),
                    subtitle: Text(c.contact.phone),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: PrimaryButton(
              label: 'Create Group (${_selectedMembers.length} members)',
              isLoading: _isCreating,
              onPressed: _createGroup,
            ),
          ),
        ],
      ),
    );
  }
}
