import 'package:flutter/material.dart';

class MessageBubble
    extends StatelessWidget {
  final String message;
  final bool isMine;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 280,
        ),

        margin:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 11,
        ),

        decoration: BoxDecoration(
          color: isMine
              ? const Color(0xFF1976D2)
              : Colors.white,

          borderRadius:
              BorderRadius.only(
            topLeft:
                const Radius.circular(18),
            topRight:
                const Radius.circular(18),

            bottomLeft: Radius.circular(
              isMine ? 18 : 4,
            ),

            bottomRight: Radius.circular(
              isMine ? 4 : 18,
            ),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(
                alpha: 0.05,
              ),
              blurRadius: 5,
              offset:
                  const Offset(0, 2),
            ),
          ],
        ),

        child: Text(
          message,
          style: TextStyle(
            color: isMine
                ? Colors.white
                : const Color(
                    0xFF1E293B,
                  ),
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}