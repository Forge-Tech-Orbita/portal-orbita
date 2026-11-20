import 'financial.dart';

const demoInvoice = Invoice(
  label: 'MENSALIDADE · NOVEMBRO',
  amount: r'R$ 1.240,00',
  dueDate: '10/12/2026',
  discount: r'− R$ 62,00',
  total: r'R$ 1.178,00',
  daysLeft: 21,
);

/// Dados fictícios de pagamento, sem valor bancário.
const demoPixCode =
    '00020126580014BR.GOV.BCB.PIX0136orbita-demo-sem-valor520400005303986'
    '5406117800';
const demoBoletoLine = '00000.00000 00000.000000 00000.000000 0 00000000000000';

const demoPayments = [
  Payment(month: 'Outubro/2026', amount: r'R$ 1.178,00'),
  Payment(month: 'Setembro/2026', amount: r'R$ 1.178,00'),
  Payment(month: 'Agosto/2026', amount: r'R$ 1.178,00'),
];
