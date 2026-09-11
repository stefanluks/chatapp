import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'chat_screen.dart';

class SearchUserScreen
    extends StatefulWidget {
  const SearchUserScreen({
    super.key,
  });

  @override
  State<SearchUserScreen>
      createState() =>
          _SearchUserScreenState();
}

class _SearchUserScreenState
    extends State<SearchUserScreen> {
  final searchController =
      TextEditingController();

  List<dynamic> users = [];

  bool loading = false;

  Future<void> search() async {
    final text =
        searchController.text.trim();

    if (text.isEmpty) {
      setState(() {
        users = [];
      });

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await ApiService
          .instance
          .searchUsers(text);

      if (!mounted) return;

      setState(() {
        users = result;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst(
                    'Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> startConversation(
    dynamic user,
  ) async {
    try {
      final response = await ApiService
          .instance
          .createConversation(
        user['id'],
      );

      final conversation =
          response['conversation'];

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId:
                conversation['id'],
            username:
                user['username'],
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst(
                    'Exception: ', ''),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Nova conversa'),
      ),

      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(16),
            child: TextField(
              controller:
                  searchController,
              autofocus: true,
              onSubmitted:
                  (_) => search(),
              decoration:
                  InputDecoration(
                labelText:
                    'Buscar username',
                hintText:
                    'Ex: maria',
                prefixIcon:
                    const Icon(
                  Icons.search,
                ),
                suffixIcon: IconButton(
                  onPressed: search,
                  icon: const Icon(
                    Icons.send,
                  ),
                ),
              ),
            ),
          ),

          if (loading)
            const LinearProgressIndicator(),

          Expanded(
            child: users.isEmpty
                ? const Center(
                    child: Text(
                      'Busque outro usuário pelo username',
                      style: TextStyle(
                        color:
                            Colors.grey,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount:
                        users.length,
                    separatorBuilder:
                        (_, __) =>
                            const Divider(
                      height: 1,
                    ),
                    itemBuilder:
                        (context, index) {
                      final user =
                          users[index];

                      return ListTile(
                        leading:
                            CircleAvatar(
                          backgroundColor:
                              const Color(
                            0xFFBBDEFB,
                          ),
                          child: Text(
                            user['username']
                                .toString()
                                .substring(
                                    0, 1)
                                .toUpperCase(),
                            style:
                                const TextStyle(
                              color: Color(
                                0xFF0D47A1,
                              ),
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user['username'],
                        ),
                        subtitle: Text(
                          '@${user['username']}',
                        ),
                        trailing:
                            const Icon(
                          Icons
                              .chat_bubble_outline,
                        ),
                        onTap: () {
                          startConversation(
                            user,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}