import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeBlock {
  final String language;
  final String code;
  final int start;
  final int end;

  CodeBlock({
    required this.language,
    required this.code,
    required this.start,
    required this.end,
  });
}

void _copyToClipboard(String text, BuildContext context) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Copied to clipboard')),
  );
}