// Fixture: the UI reaching past its ViewModel into the data layer is a BLOCKER.

import 'package:flutter/material.dart';

import '../data/cart_api_client.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
