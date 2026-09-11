import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final String username;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.username,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {
  final messageController =
      TextEditingController();

  final scrollController =
      ScrollController();

  List<dynamic> messages = [];

  bool loading = true;
  bool sending = false;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    loadMessages(
      scrollToBottom: true,
    );

    /*
      Como ainda não estamos usando
      Socket.IO, verificamos novas
      mensagens periodicamente.
    */

    timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) {
        loadMessages();
      },
    );
  }

  Future<void> loadMessages({
    bool scrollToBottom = false,
  }) async {
    try {
      final data = await ApiService
          .instance
          .getMessages(
        widget.conversationId,
      );

      if (!mounted) return;

      final oldLength =
          messages.length;

      setState(() {
        messages = data;
        loading = false;
      });

      if (scrollToBottom ||
          data.length > oldLength) {
        WidgetsBinding.instance
            .addPostFrameCallback(
          (_) {
            scrollToEnd();
          },
        );
      }
    } catch (_) {
      if (mounted && loading) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> sendMessage() async {
    final text =
        messageController.text.trim();

    if (text.isEmpty || sending) {
      return;
    }

    messageController.clear();

    setState(() {
      sending = true;
    });

    try {
      await ApiService.instance
          .sendMessage(
        widget.conversationId,
        text,
      );

      await loadMessages(
        scrollToBottom: true,
      );
    } catch (error) {
      if (!mounted) return;

      messageController.text =
          text;

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
          sending = false;
        });
      }
    }
  }

  void scrollToEnd() {
    if (!scrollController
        .hasClients) {
      return;
    }

    scrollController.animateTo(
      scrollController
          .position
          .maxScrollExtent,
      duration:
          const Duration(
        milliseconds: 250,
      ),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    timer?.cancel();

    messageController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFEFF4FA),

      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor:
                  const Color(
                0xFFBBDEFB,
              ),
              child: Text(
                widget.username
                    .substring(0, 1)
                    .toUpperCase(),
                style:
                    const TextStyle(
                  color: Color(
                    0xFF0D47A1,
                  ),
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username,
                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const Text(
                  'SLChat',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize:
                              MainAxisSize
                                  .min,
                          children: [
                            Icon(
                              Icons
                                  .chat_bubble_outline,
                              size: 60,
                              color:
                                  Colors.grey,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Envie a primeira mensagem',
                              style:
                                  TextStyle(
                                color:
                                    Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller:
                            scrollController,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 12,
                        ),

                        itemCount:
                            messages
                                .length,

                        itemBuilder:
                            (context,
                                index) {
                          final message =
                              messages[
                                  index];

                          return MessageBubble(
                            message:
                                message[
                                    'content'],

                            isMine:
                                message[
                                        'isMine'] ==
                                    true,
                          );
                        },
                      ),
          ),

          Container(
            padding:
                const EdgeInsets.fromLTRB(
              10,
              8,
              10,
              12,
            ),

            color: Colors.white,

            child: SafeArea(
              top: false,

              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          messageController,

                      minLines: 1,
                      maxLines: 5,

                      textCapitalization:
                          TextCapitalization
                              .sentences,

                      decoration:
                          const InputDecoration(
                        hintText:
                            'Digite uma mensagem...',
                        contentPadding:
                            EdgeInsets
                                .symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),

                      onSubmitted:
                          (_) =>
                              sendMessage(),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  SizedBox(
                    width: 50,
                    height: 50,
                    child:
                        FloatingActionButton(
                      heroTag:
                          'sendMessage',

                      onPressed:
                          sending
                              ? null
                              : sendMessage,

                      backgroundColor:
                          const Color(
                        0xFF1565C0,
                      ),

                      foregroundColor:
                          Colors.white,

                      elevation: 0,

                      child: sending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color:
                                    Colors
                                        .white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}