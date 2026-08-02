// Fixture: UI-craft violations that dart-hygiene-check.sh must catch, each
// named in its output. This file is SUPPOSED to be wrong — it is how
// self-test proves the UI-craft scans still fire. Never "fix" it.

import 'package:flutter/material.dart';

class CheapDashboard extends StatelessWidget {
  const CheapDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,                    // BLOCKER factory palette colour
      padding: const EdgeInsets.all(13),     // MAJOR raw spacing literal
      child: Column(
        children: [
          const SizedBox(height: 7),         // MAJOR raw spacing literal
          const Text('Sales', style: TextStyle(fontSize: 14)), // MAJOR fontSize literal
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.green), // BLOCKER factory palette
            onPressed: () {},
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
