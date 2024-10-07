import 'package:flutter/material.dart';

class MyRouteObserver extends RouteObserver<Route<dynamic>> {
  void _sendScreenView(PageRoute<dynamic> route) {
    final screenName = route.settings.name;
    debugPrint('screenName: $screenName');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}
