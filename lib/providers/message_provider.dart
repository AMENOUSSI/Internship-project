import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageProvider with ChangeNotifier {
  List<Message> _messages = [];

  List<Message> get messages => _messages;

  void addMessage(String content, String sender, {bool isVoice = false}) {
    _messages.add(Message(content: content, sender: sender, isVoice: isVoice));
    notifyListeners();
  }
}
