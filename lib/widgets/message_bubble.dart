import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isFromUser;
  final bool isVoice;

  const MessageBubble({
    required this.content,
    required this.isFromUser,
    this.isVoice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isFromUser ? Colors.green[800] : Colors.grey[300],
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5), // Couleur de l'ombre
              spreadRadius: 5, // Rayon de diffusion
              blurRadius: 7, // Rayon de flou
              offset: Offset(0, 3), // Décalage horizontal et vertical
            ),
          ],
        ),
        child: isVoice
            ? Icon(Icons.play_arrow)
            : Text(content,
                style:
                    TextStyle(color: isFromUser ? Colors.white : Colors.black)),
      ),
    );
  }
}
