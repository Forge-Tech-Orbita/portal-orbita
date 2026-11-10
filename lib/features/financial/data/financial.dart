// shortcut: valores formatados apenas para exibição, usar centavos inteiros ao integrar cobrança real.
class Invoice {
  const Invoice({
    required this.label,
    required this.amount,
    required this.dueDate,
    required this.discount,
  });

  final String label;
  final String amount;
  final String dueDate;
  final String discount;
}

class Payment {
  const Payment({required this.month, required this.amount});

  final String month;
  final String amount;
}
