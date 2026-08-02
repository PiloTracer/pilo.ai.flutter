// Fixture: a Flutter import inside domain/ is a BLOCKER (FLS-03).
//
// This is the single check that keeps the domain layer testable, portable and
// free of framework lifecycle. It must never stop firing.

import 'package:flutter/material.dart';

class Order {
  const Order(this.accent);

  final Color accent;
}
