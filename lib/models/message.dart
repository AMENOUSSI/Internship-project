class Message {
  final String content;
  final String sender;
  final bool isVoice;
  final String? audioUrl; // Ajout de l'URL audio pour les messages vocaux

  Message({
    required this.content,
    required this.sender,
    this.isVoice = false,
    this.audioUrl,
  });
}
