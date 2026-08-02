// Fixture: theme files DEFINE the raw values the UI-craft scans forbid in
// widgets. The path-level theme exemption must keep this file clean — if a
// scan starts firing here, every project's token file reports findings and
// the check gets switched off. Must produce ZERO hygiene findings.

import 'package:flutter/material.dart';

/// Brand palette. The ONLY place raw colour values are allowed.
class AppColors {
  static const seed = Color(0xFF1D6FE0);
  static const accent = Color(0xFF0E9F8A);
  static const neutral900 = Color(0xFF1A1A1E);
  static const scaffold = Colors.white;
}

/// The spacing scale: multiples of 4 so every combination lands on one grid.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Display style for the one dominant element per screen (2.5x the body).
const dominantStyle = TextStyle(fontSize: 40, fontWeight: FontWeight.w700);
