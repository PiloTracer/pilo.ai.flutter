// Fixture: must produce ZERO hygiene findings.
//
// A checker that fires on correct code gets disabled, and a disabled check
// produces silence that reads as health. Any new scan must leave this file
// clean.

import 'package:flutter/material.dart';

/// A card showing a user's display name.
class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      // Sized by the parent list; no intrinsic measurement needed here.
      child: Text(name, style: theme.textTheme.bodyLarge),
    );
  }
}

/// A bounded list. `ListView.builder` because the count comes from data.
class UserList extends StatelessWidget {
  const UserList({super.key, required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: names.length,
      itemBuilder: (context, index) => UserCard(name: names[index]),
    );
  }
}

// TODO(ana): support avatars once the asset pipeline lands.
// ignore_for_file: deprecated_member_use — upstream fix tracked in ADR-004
