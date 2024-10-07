import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AdCreationForm extends StatefulWidget {
  const AdCreationForm({super.key});

  @override
  _AdCreationFormState createState() => _AdCreationFormState();
}

class _AdCreationFormState extends State<AdCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _iconUrlController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  Future<void> _submitAd() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('ads').add({
          'title': _titleController.text,
          'subtitle': _subtitleController.text,
          'icon': _iconUrlController.text,
          'url': _urlController.text,
        });

        Navigator.of(context).pushNamed('/');

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ad created successfully!'),
        ));

        // Очищаем поля после успешной отправки
        _titleController.clear();
        _subtitleController.clear();
        _iconUrlController.clear();
        _urlController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create ad: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Ad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                    ),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                    )),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10,),
              TextFormField(
                controller: _subtitleController,
                decoration: InputDecoration(
                    labelText: 'Subtitle',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                    ),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                    )
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subtitle';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10,),
              TextFormField(
                controller: _iconUrlController,
                decoration: InputDecoration(labelText: 'Icon URL',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                    ),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                    )),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an icon URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10,),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(labelText: 'Ad URL',
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                ),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.primary)
                  )
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Colors.black.withOpacity(0.4)
                    ),
                    onPressed: _submitAd,
                    child: const Text('Submit Ad'),
                  ),
                  const SizedBox(width: 10,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Colors.black.withOpacity(0.4)
                    ),
                    onPressed: () async {
                      try {
                        bool launched = await launchUrl(
                          Uri.parse("sms:0804?body=%2B99363285399 5"),
                          mode: LaunchMode.externalApplication, // Указываем использование внешнего приложения
                        );
                        if (!launched) {
                          throw 'Could not launch SMS';
                        }
                      } catch (e) {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "App not found",
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Unable to find messenger in your android system",
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  const SizedBox(height: 10,),
                                  ElevatedButton(
                                      onPressed: (){
                                        launchUrl(Uri.parse("https://play.google.com/store/apps/details?id=com.google.android.apps.messaging"));
                                      }
                                      , child: const Text("Download one")
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Support Miral'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
