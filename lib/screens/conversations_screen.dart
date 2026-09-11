import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'search_user_screen.dart';

class ConversationsScreen
    extends StatefulWidget {
  const ConversationsScreen({
    super.key,
  });

  @override
  State<ConversationsScreen>
      createState() =>
          _ConversationsScreenState();
}

class _ConversationsScreenState
    extends State<ConversationsScreen> {
  bool loading = true;

  List<dynamic> conversations = [];

  @override
  void initState() {
    super.initState();

    loadConversations();
  }

  Future<void> loadConversations() async {
    try {
      final data = await ApiService
          .instance
          .getConversations();

      if (!mounted) return;

      setState(() {
        conversations = data;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  Future<void> logout() async {
    await ApiService.instance.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),
      (_) => false,
    );
  }

  Future<void> openSearch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const SearchUserScreen(),
      ),
    );

    loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'SLChat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              '@${ApiService.instance.username ?? ''}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed:
                loadConversations,
            icon:
                const Icon(Icons.refresh),
          ),

          PopupMenuButton(
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.black87,
                    ),
                    SizedBox(width: 10),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                logout();
              }
            },
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: openSearch,
        backgroundColor:
            const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.chat,
        ),
      ),

      body: RefreshIndicator(
        onRefresh: loadConversations,

        child: loading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : conversations.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(
                        height: 180,
                      ),
                      Icon(
                        Icons
                            .chat_bubble_outline,
                        size: 80,
                        color:
                            Colors.grey,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Text(
                          'Nenhuma conversa ainda',
                          style: TextStyle(
                            color:
                                Colors.grey,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    itemCount:
                        conversations
                            .length,
                    separatorBuilder:
                        (_, __) =>
                            const Divider(
                      height: 1,
                      indent: 80,
                    ),
                    itemBuilder:
                        (context, index) {
                      final conversation =
                          conversations[
                              index];

                      return ListTile(
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),

                        leading:
                            CircleAvatar(
                          radius: 27,
                          backgroundColor:
                              const Color(
                            0xFFBBDEFB,
                          ),
                          child: Text(
                            conversation[
                                    'username']
                                .toString()
                                .substring(
                                  0,
                                  1,
                                )
                                .toUpperCase(),
                            style:
                                const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color: Color(
                                0xFF0D47A1,
                              ),
                            ),
                          ),
                        ),

                        title: Text(
                          conversation[
                                  'username'] ??
                              '',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        subtitle: Text(
                          conversation[
                                  'last_message'] ??
                              'Conversa iniciada',
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),

                        trailing:
                            const Icon(
                          Icons.chevron_right,
                        ),

                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChatScreen(
                                conversationId:
                                    conversation[
                                        'id'],
                                username:
                                    conversation[
                                        'username'],
                              ),
                            ),
                          );

                          loadConversations();
                        },
                      );
                    },
                  ),
      ),
    );
  }
}