import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool mine;

  ChatMessage(this.data, this.mine);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> _infoMsg = data['msg'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child:
          mine ? RightAlign(_infoMsg, context) : LeftAlign(_infoMsg, context),
    );
  }

  Row RightAlign(Map<String, dynamic> _infoMsg, BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _infoMsg['senderName'],
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 8,
                  ),
                ),
              ),
              _verificaConteudo(context, _infoMsg),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(_infoMsg['senderPhotoUrl']),
          ),
        ),
      ],
    );
  }

  Row LeftAlign(Map<String, dynamic> _infoMsg, BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(_infoMsg['senderPhotoUrl']),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _infoMsg['senderName'],
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 8,
                  ),
                ),
              ),
              _verificaConteudo(context, _infoMsg),
            ],
          ),
        ),
      ],
    );
  }

  Widget _verificaConteudo(BuildContext context, Map<String, dynamic> info) {
    if (info['imgUrl'] != null) {
      return Image.network(
        info['imgUrl'],
        width: 250,
      );
    } else
      return Text(info['message']);
  }
}
