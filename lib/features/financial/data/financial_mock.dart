import 'financial.dart';

const demoInvoice = Invoice(
  label: 'MENSALIDADE · SETEMBRO',
  amount: r'R$ 1.240,00',
  dueDate: '10/09/2026',
  discount: r'− R$ 62,00',
  netAmount: r'R$ 1.178,00',
  barcode: '34191.79001 01043.510047 91020.150008 5 910000124000',
  pixCode: '00020126580014br.gov.bcb.pix0136123e4567-e89b-12d3-a456-42661417400052040000530398654071178.005802BR5913PORTAL ORBITA6009SAO PAULO62070503***6304ABCD',
);

const demoPayments = [
  Payment(month: 'Agosto/2026', amount: r'R$ 1.178,00'),
  Payment(month: 'Julho/2026', amount: r'R$ 1.178,00'),
  Payment(month: 'Junho/2026', amount: r'R$ 1.178,00'),
  Payment(month: 'Maio/2026', amount: r'R$ 1.178,00'),
];
