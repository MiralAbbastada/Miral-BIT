import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui_auth;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AuthenticationGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              ui_auth.EmailAuthProvider(),
              // Добавь другие провайдеры, если нужно
            ],
          );
        } else {
          return ChatScreen(); // Переход в чат после успешного входа
        }
      },
    );
  }
}


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  String? _replyingToMessage;  // Строка для хранения текста сообщения, на которое отвечаем

  User? user = FirebaseAuth.instance.currentUser;

  Future<void> sendMessage(String message, {String? imageUrl}) async {
    await _firestore.collection('chats').add({
      'text': message,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.now(),
      'userId': user?.uid ?? 'Anonymous',
      'email': user?.email ?? 'Anonymous', // Добавляем поле email
      'replyToMessage': _replyingToMessage,  // Добавляем ответ на сообщение
    });

    // Сбрасываем состояние ответа после отправки
    setState(() {
      _replyingToMessage = null;
    });

    _scrollToBottom();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupFirebaseMessaging();
    _initializeLocalNotifications();
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon'); // Убедитесь, что вы добавили иконку приложения

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('your_channel_id', 'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics,
        payload: 'item x');
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print("${message.notification!.title!}, ${message.notification!.body!}");
        // Здесь вы можете вызвать показ уведомления с помощью Flutter Local Notifications
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");

    // Сохраните токен в Firestore, ассоциировав его с пользователем
    await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
      'fcmToken': token,
    });
  }

  Future<void> _sendImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = Uuid().v4();
      Reference ref = _storage.ref().child('chat_images').child('$fileName.jpg');
      await ref.putFile(imageFile);
      String downloadURL = await ref.getDownloadURL();
      await sendMessage('', imageUrl: downloadURL);
    }
  }

  void _sendTextMessage() {
    if (_controller.text.isNotEmpty) {
      sendMessage(_controller.text);
      _controller.clear();
    }
  }

  void _showImageFullScreen(String imageUrl) {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: Text('Image View'),
        ),
        body: Center(
          child: Image.network(imageUrl),
        ),
      );
    }));
  }

  Future<void> _deleteMessage(DocumentSnapshot document) async {
    await _firestore.collection('chats').doc(document.id).delete();
  }

  void _replyToMessage(String message) {
    setState(() {
      _replyingToMessage = message;  // Устанавливаем сообщение, на которое отвечаем
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'), // Замените на ваш путь
            fit: BoxFit.cover, // Выберите подходящий способ заполнения
          ),
        ),
        child: Column(
          children: [
            if (_replyingToMessage != null)  // Если есть сообщение для ответа
              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Replying to: $_replyingToMessage',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _replyingToMessage = null;  // Сбрасываем ответ
                        });
                      },
                    ),
                  ],
                ),
              ),
            Expanded(
              child: StreamBuilder(
                stream: _firestore.collection('chats').orderBy('createdAt').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 10),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      bool isCurrentUser = document['userId'] == user?.uid;
                      return GestureDetector(
                        onLongPress: () {
                          _showMessageOptions(document);
                        },
                        child: Align(
                          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Card(
                            color: isCurrentUser
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                                : Colors.black.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    document['email'] ?? 'Unknown User',  // Проверка на наличие поля email
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isCurrentUser
                                          ? Colors.white
                                          : Colors.white,
                                    ),
                                  ),
                                  if (document['replyToMessage'] != null)  // Если есть текст, на который ответили
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      margin: EdgeInsets.only(bottom: 8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Reply to: ${document['replyToMessage']}',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  if (document['text'] != null && document['text'].isNotEmpty)
                                    Text(
                                      document['text'],
                                      style: TextStyle(
                                        color: isCurrentUser ? Colors.white : Colors.white,
                                      ),
                                    ),
                                  if (document['imageUrl'] != null)
                                    GestureDetector(
                                      onTap: () {
                                        _showImageFullScreen(document['imageUrl']);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Image.network(
                                          document['imageUrl'],
                                          height: 150,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    DateFormat.Hm().format((document['createdAt'] as Timestamp).toDate()),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isCurrentUser ? Colors.white : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.6),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.photo),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: _sendImage,
                    ),
                    Expanded(
                      child: TextField(
                        maxLines: 5, // Максимальное количество строк
                        minLines: 1, // Минимальное количество строк
                        keyboardType: TextInputType.multiline,
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Send a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed:
                        _sendTextMessage,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(DocumentSnapshot document) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.reply, color: Theme.of(context).colorScheme.primary,),
            title: Text('Reply', style: TextStyle(color: Theme.of(context).colorScheme.primary),),
            onTap: () {
              _replyToMessage(document['text'] ?? '');  // Устанавливаем сообщение для ответа
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red,),
            title: Text('Delete', style: TextStyle(color: Colors.red),),
            onTap: () {
              _deleteMessage(document);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
