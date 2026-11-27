import 'dart:async';

import 'package:flutter/material.dart';

class NavigationRefreshObserver extends NavigatorObserver {
  static const _delay = Duration(seconds: 2);

  final isLoading = ValueNotifier(false);
  Timer? _timer;
  bool _hasInitialRoute = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (!_hasInitialRoute) {
      _hasInitialRoute = true;
      return;
    }
    _showLoading();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _showLoading();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (_hasInitialRoute) _showLoading();
  }

  void _showLoading() {
    _timer?.cancel();
    isLoading.value = true;
    _timer = Timer(_delay, () {
      isLoading.value = false;
    });
  }
}

final navigationRefreshObserver = NavigationRefreshObserver();

class NavigationLoadingBody extends StatelessWidget {
  const NavigationLoadingBody({required this.child, this.loading, super.key});

  final Widget child;
  final ValueNotifier<bool>? loading;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: loading ?? navigationRefreshObserver.isLoading,
      builder: (context, isLoading, _) =>
          isLoading ? const Center(child: CircularProgressIndicator()) : child,
    );
  }
}
