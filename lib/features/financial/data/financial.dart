// shortcut: valores formatados apenas para exibição, usar centavos inteiros ao integrar cobrança real.
class Invoice {
  const Invoice({
    required this.label,
    required this.amount,
    required this.dueDate,
    required this.discount,
    this.netAmount = r'R$ 1.178,00',
    this.barcode = '34191.79001 01043.510047 91020.150008 5 910000124000',
    this.pixCode = '00020126580014br.gov.bcb.pix0136123e4567-e89b-12d3-a456-42661417400052040000530398654071178.005802BR5913PORTAL ORBITA6009SAO PAULO62070503***6304ABCD',
  });

  final String label;
  final String amount;
  final String dueDate;
  final String discount;
  final String netAmount;
  final String barcode;
  final String pixCode;
}

class Payment {
  const Payment({required this.month, required this.amount});

  final String month;
  final String amount;
}
