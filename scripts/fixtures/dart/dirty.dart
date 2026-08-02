// Fixture: every line below must be caught by dart-hygiene-check.sh.
//
// The expected finding count is asserted in self-test.sh. If a scan regresses
// into silence, this file stops matching and the self-test fails.

import 'package:flutter/material.dart';

class BadWidget extends StatelessWidget {
  const BadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    print('rendering');                                 // BLOCKER print
    final w = MediaQuery.of(context).size.width;        // MAJOR  MediaQuery layout
    // final legacy = oldThing();                       // MINOR  commented-out code
    return Container(
      color: Color(0xFF1A2B3C),                         // BLOCKER colour literal
      width: w,
      child: const Text('a'),
    );
  }

  Future<void> load() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300)); // MAJOR sync-by-sleep
      await fetch('http://api.example.com/data');              // MAJOR cleartext
    } catch (e) {}                                             // MAJOR empty catch
  }

  // TODO: fix this                                     // MAJOR unowned TODO
  // ignore: unused_element                             // MAJOR unexplained ignore
  void _x() {}

  Future<void> fetch(String url) async {}
}
