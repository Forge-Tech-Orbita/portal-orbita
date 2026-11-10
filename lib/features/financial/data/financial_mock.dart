import 'financial.dart';

const demoInvoice = Invoice(
  label: 'MENSALIDADE · SETEMBRO',
  amount: r'R$ 1.240,00',
  dueDate: '10/09/2026',
  discount: r'− R$ 62,00',
);

const demoPayments = [
  Payment(month: 'Agosto/2026', amount: r'R$ 1.178,00'),
  Payment(month: 'Julho/2026', amount: r'R$ 1.178,00'),
  Payment(month: 'Junho/2026', amount: r'R$ 1.178,00'),
  Payment(month: 'Maio/2026', amount: r'R$ 1.178,00'),
];
