import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  void showMessage(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(this);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFFF5B5B) : null,
      ),
    );
  }
}
