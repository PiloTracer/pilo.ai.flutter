// Fixture: a repository importing another repository is a BLOCKER.
//
// Importing its own interface is correct and must NOT be reported.

import '../domain/order_repository.dart';
import 'user_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl(this._users);

  final UserRepository _users;
}
