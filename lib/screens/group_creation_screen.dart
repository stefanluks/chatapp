import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'chat_screen.dart';

class GroupCreationScreen extends StatefulWidget {
  const GroupCreationScreen({super.key});

  @override
  State<GroupCreationScreen> createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  final searchController = TextEditingController();
  final selectedUsers = <int, String>{};

  List<dynamic> users = [];
  bool loading = false;
  bool creating = false;

  Future<void> search() async {
    final text = searchController.text.trim();

    if (text.isEmpty) {
      setState(() => users = []);
      return;
    }

    setState(() => loading = true);

    try {
      final result = await ApiService.instance.searchUsers(text);

      if (mounted) {
        setState(() {
          users = result.where((user) => !_isCurrentUser(user)).toList();
          final currentUserId = ApiService.instance.userId;
          if (currentUserId != null) {
            selectedUsers.remove(currentUserId);
          }
        });
      }
    } catch (error) {
      if (mounted) {
        _showError(error);
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void toggleUser(dynamic user) {
    if (_isCurrentUser(user)) return;

    final id = user['id'] as int;
    final username = user['username'].toString();

    setState(() {
      if (selectedUsers.containsKey(id)) {
        selectedUsers.remove(id);
      } else {
        selectedUsers[id] = username;
      }
    });
  }

  bool _isCurrentUser(dynamic user) {
    final currentUserId = ApiService.instance.userId;
    final currentUsername = ApiService.instance.username;

    return (currentUserId != null && user['id'] == currentUserId) ||
        (currentUsername != null &&
            user['username'].toString().toLowerCase() ==
                currentUsername.toLowerCase());
  }

  Future<void> createGroup() async {
    if (selectedUsers.length < 2 || creating) return;

    final participantIds = selectedUsers.keys
        .where((id) => id != ApiService.instance.userId)
        .toList();

    if (participantIds.length < 2) {
      _showError('Selecione pelo menos duas outras pessoas para o grupo.');
      return;
    }

    setState(() => creating = true);

    try {
      final response = await ApiService.instance.createGroupConversation(
        participantIds,
      );
      final conversation = response['conversation'] as Map<String, dynamic>;
      final groupName =
          conversation['name']?.toString() ?? selectedUsers.values.join(', ');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversation['id'] as int,
            username: groupName,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        _showError(error);
      }
    } finally {
      if (mounted) {
        setState(() => creating = false);
      }
    }
  }

  void _showError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo grupo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              autofocus: true,
              onSubmitted: (_) => search(),
              decoration: InputDecoration(
                labelText: 'Adicionar participantes',
                hintText: 'Ex: maria',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: search,
                  icon: const Icon(Icons.send),
                ),
              ),
            ),
          ),
          if (selectedUsers.isNotEmpty)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: selectedUsers.entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Chip(
                          label: Text(entry.value),
                          onDeleted: () =>
                              setState(() => selectedUsers.remove(entry.key)),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (loading) const LinearProgressIndicator(),
          Expanded(
            child: users.isEmpty
                ? const Center(
                    child: Text(
                      'Busque usuários e selecione pelo menos dois',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final id = user['id'] as int;

                      return CheckboxListTile(
                        value: selectedUsers.containsKey(id),
                        onChanged: (_) => toggleUser(user),
                        secondary: CircleAvatar(
                          backgroundColor: const Color(0xFFBBDEFB),
                          child: Text(
                            user['username']
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(user['username']),
                        subtitle: Text('@${user['username']}'),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: selectedUsers.length >= 2 && !creating
                    ? createGroup
                    : null,
                icon: creating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.group_add),
                label: Text(
                  creating
                      ? 'Criando grupo...'
                      : 'Criar grupo (${selectedUsers.length})',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
