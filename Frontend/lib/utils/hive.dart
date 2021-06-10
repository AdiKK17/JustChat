import '../models/user.dart';
import 'package:hive/hive.dart';

class HiveBoxNames {
  static const String orderBox = 'orders';
  static const String userBox = 'user';
  static const String authBox = 'auth';
  static const String buyer = 'buyer';
  static const String supplier = 'supplier';
  static const String customers = 'customers';
  static const String supplierBuyers = 'supplier_buyers';
  static const String buyerSuppliers = 'buyer_suppliers';
  static const String products = 'products';
  static const String chatrooms = 'chatrooms';
  static const String invite = 'invite';
  static const String cart = 'cart';
}

Future<void> clearHive() async {
  Box<User> user = await Hive.openBox(HiveBoxNames.userBox);
  await user.clear();
  print('Cleared Hive DB');
}
