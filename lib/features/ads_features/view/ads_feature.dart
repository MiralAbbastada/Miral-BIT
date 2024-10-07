import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/ad_bloc.dart';
import '../bloc/ad_bloc_state.dart';

class AdsWidget extends StatelessWidget {
  final Color backgroundColor;
  final Border? border;

  const AdsWidget({super.key, 
    this.backgroundColor = const Color(0xFF131313),
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdBloc, AdState>(
      builder: (context, state) {
        if (state is AdLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AdLoaded) {
          final ad = state.adData;
          return Dismissible(
            key: UniqueKey(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: border, // возможность кастомизировать границы
              ),
              margin: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Advertisement | Miral Ads",
                    style: TextStyle(fontSize: 10, color: Colors.white30),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        ad['icon'],
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad['title'],
                              style: const TextStyle(fontSize: 15, color: Colors.white),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              ad['subtitle'],
                              style: const TextStyle(fontSize: 15, color: Colors.white),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        final url = ad['url'];
                        launchUrl(Uri.parse(url));
                      },
                      child: const Text("Visit"),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is AdEmpty) {
          return const Center(child: Text('No ads available'));
        } else {
          return const Center(child: Text('Error loading ads'));
        }
      },
    );
  }
}
