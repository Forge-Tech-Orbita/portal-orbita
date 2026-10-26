import { PaymentHistoryEntry } from '../types';

export const invoice = {
  referenceLabel: 'MENSALIDADE · SETEMBRO',
  amount: 'R$ 1.240,00',
  dueDate: '10/09/2026',
  punctualityDiscount: '− R$ 62,00',
};

export const paymentHistory: PaymentHistoryEntry[] = [
  { month: 'Agosto/2026', amount: 'Pago · R$ 1.178,00' },
  { month: 'Julho/2026', amount: 'Pago · R$ 1.178,00' },
  { month: 'Junho/2026', amount: 'Pago · R$ 1.178,00' },
  { month: 'Maio/2026', amount: 'Pago · R$ 1.178,00' },
];
