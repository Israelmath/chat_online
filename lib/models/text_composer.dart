import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {

  final Function({String message, PickedFile imageFile}) sendMessage;

  TextComposer(this.sendMessage);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  TextEditingController _messageController = TextEditingController();

  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              final PickedFile imgFile = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
              if(imgFile == null) return;
              _reset();
              widget.sendMessage(imageFile: imgFile);
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration:
                  InputDecoration.collapsed(hintText: 'Enviar mensagem'),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage(message: text);
                print('Text: $text');
                _reset();
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
            ),
            onPressed: _isComposing ? (){
              print(_messageController.text);
              widget.sendMessage(message: _messageController.text);
            _reset();
          } : null,
          ),
        ],
      ),
    );
  }

  void _reset() {
    _messageController.clear();
    setState(() {
      _isComposing = false;
    });
  }
}
