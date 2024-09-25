import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../services/api_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone
        .request(); // Demander la permission du microphone
    await _recorder.openRecorder();
  }

  void _sendTextMessage() async {
    String messageText = _controller.text.trim();
    if (messageText.isEmpty) return;

    Provider.of<MessageProvider>(context, listen: false)
        .addMessage(messageText, 'user');
    String botResponse = await ApiService.sendMessage(messageText);
    Provider.of<MessageProvider>(context, listen: false)
        .addMessage(botResponse, 'bot');
    _controller.clear();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/temp_audio.aac';

    await _recorder.startRecorder(toFile: path);
    setState(() {
      _isRecording = true;
      _audioPath = path;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    if (_audioPath != null) {
      File audioFile = File(_audioPath!);

      // Envoyer le fichier audio au serveur
      String botResponse = await ApiService.sendAudio(audioFile);
      Provider.of<MessageProvider>(context, listen: false)
          .addMessage(botResponse, 'bot', isVoice: true);
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Voici ton meilleur assistant AI",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                return ListView.builder(
                  itemCount: messageProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = messageProvider.messages[index];
                    return MessageBubble(
                      content: message.content,
                      isFromUser: message.sender == 'user',
                      isVoice: message.isVoice,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        InputDecoration(hintText: "Envoyer un message..."),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.green[800],
                  ),
                  onPressed: _sendTextMessage,
                ),
                IconButton(
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic,
                      color: Colors.green[800]),
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
