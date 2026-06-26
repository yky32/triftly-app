import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shown when startup fails before the main app can load.
class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({
    required this.error,
    this.stackTrace,
    super.key,
  });

  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    final details = stackTrace == null ? '$error' : '$error\n\n$stackTrace';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Triftly could not start',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Something went wrong during startup. You can copy the '
                  'details below and share them for support.',
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      details,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Clipboard.setData(ClipboardData(text: details)),
                  child: const Text('Copy error'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
