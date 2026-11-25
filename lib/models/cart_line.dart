import 'menu_item.dart';

class CartLine {
  final MenuItem item;
  int qty;
  CartLine(this.item, this.qty);

  double get subtotal => item.price * qty;
}
