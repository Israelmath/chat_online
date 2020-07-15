import 'dart:io';

import 'package:chat/models/ChatMessage.dart';
import 'package:chat/models/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser _currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();



  @override
  void initState() {
    FirebaseAuth.instance.onAuthStateChanged.listen((usr){
      setState(() {
        _currentUser = usr;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if(_currentUser != null) return _currentUser;

    try {
      // Pega a conta do usuário
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      // Pega a autenticação do usuário
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      // Tenta fazer a autenticação
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      final AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      final FirebaseUser user = await authResult.user;
      return user;
    }
    catch (error) {
      return null;
    }
  }

  void _sendMessage({String message, PickedFile imageFile}) async {
    final FirebaseUser user = await _getUser();
    print(user.displayName);

    if (user == null){
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text('Não foi possível fazer o login. Tente novamente'),
            backgroundColor: Colors.red,
      ));
    }

    Map<String, dynamic> data = {
      'uuid' : user.uid,
      'senderName' : user.displayName,
      'senderPhotoUrl' : user.photoUrl,
      'time' : Timestamp.now()
    };

    if (imageFile != null) {
      final _image = File(imageFile.path);
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(_image);

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String imgUrl = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = imgUrl;
    }
    if (message != null) data['message'] = message;

    Firestore.instance.collection('mensagens').add({'msg': data});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: <Widget>[
          LogIO(),
        ],
        title: Text(_checkUser()),
        centerTitle: true,
        elevation: 10,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('mensagens').snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: RefreshProgressIndicator(),
                    );

                  default:
                    List<DocumentSnapshot> docs =
                        snapshot.data.documents.toList();

                    return ListView.builder(
                      itemCount: docs.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        bool _showCard =
                            docs[index].data['msg']['message'] != null
                                ? true
                                : false;
                        return ChatMessage(docs[index].data, true);
                      },
                    );
                }
              },
            ),
          ),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }

  String _checkUser() {
    if(_currentUser != null){
      return 'Olá, ${_currentUser.displayName}';
    }
    else return 'TeleApp';
  }

  LogIO() {
    if(_currentUser != null){
      return IconButton(icon: Icon(Icons.exit_to_app), onPressed: (){
        FirebaseAuth.instance.signOut();
        googleSignIn.signOut();
      },);
    }
    else return Container();
  }
}

