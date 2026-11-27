import 'dart:async';

import 'package:flutter/material.dart';

class LoadingState extends StatefulWidget {
  const LoadingState({
    super.key,
    this.size,
    this.strokeWidth = 4,
    this.color,
    this.onRefresh,
    this.refreshDelay = const Duration(seconds: 2),
    this.showIndicator = true,
    this.message,
  });

  final double? size;
  final double strokeWidth;
  final Color? color;
  final VoidCallback? onRefresh;
  final Duration refreshDelay;
  final bool showIndicator;
  final String? message;

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState> {
  Timer? _refreshTimer;
  bool _showRefreshButton = false;

  @override
  void initState() {
    super.initState();
    _scheduleRefreshButton();
  }

  @override
  void didUpdateWidget(covariant LoadingState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onRefresh != widget.onRefresh ||
        oldWidget.refreshDelay != widget.refreshDelay) {
      _scheduleRefreshButton();
    }
  }

  void _scheduleRefreshButton() {
    _refreshTimer?.cancel();
    _showRefreshButton = false;
    if (widget.onRefresh == null || widget.size != null) return;

    _refreshTimer = Timer(widget.refreshDelay, () {
      if (mounted) setState(() => _showRefreshButton = true);
    });
  }

  void _handleRefresh() {
    final onRefresh = widget.onRefresh;
    if (onRefresh == null) return;
    setState(() => _showRefreshButton = false);
    _scheduleRefreshButton();
    onRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      color: widget.color ?? Theme.of(context).colorScheme.primary,
      strokeWidth: widget.strokeWidth,
    );

    if (widget.size != null && widget.showIndicator) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: indicator,
      );
    }
    if (widget.showIndicator && widget.onRefresh == null) return indicator;

    final children = <Widget>[];
    if (widget.showIndicator) {
      children.add(indicator);
    } else if (widget.message != null) {
      children.add(Text(widget.message!, textAlign: TextAlign.center));
    }
    if (_showRefreshButton) {
      children.addAll([
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _handleRefresh,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ]);
    }
    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}
