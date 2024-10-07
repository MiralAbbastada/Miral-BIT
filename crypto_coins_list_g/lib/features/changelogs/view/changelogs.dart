import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChangeLogs extends StatefulWidget {
  const ChangeLogs({super.key});

  @override
  State<ChangeLogs> createState() => _ChangeLogsState();
}

class _ChangeLogsState extends State<ChangeLogs> {
  // Ссылка на коллекцию с обновлениями
  final CollectionReference _changeLogsCollection =
  FirebaseFirestore.instance.collection('changelogs');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Change logs",
          style: TextStyle(color: Colors.white),
        ),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white,),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _changeLogsCollection.orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading change logs"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              var log = logs[index];
              return ListTile(
                title: Text(
                  log['version'].toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                subtitle: Text(
                  log['description'].toString(),
                  style: const TextStyle(color: Colors.white54, fontSize: 20),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
