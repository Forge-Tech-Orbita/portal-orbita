import 'loan.dart';

const demoLoans = [
  Loan(
    title: 'Estruturas de Dados e Algoritmos',
    author: 'T. Cormen',
    dueDate: '21/11',
    daysRemaining: 2,
    dueSoon: true,
    category: LibraryCategory.computing,
  ),
  Loan(
    title: 'Arquitetura Limpa',
    author: 'R. C. Martin',
    dueDate: '01/12',
    daysRemaining: 12,
    dueSoon: false,
    category: LibraryCategory.computing,
  ),
  Loan(
    title: 'Redes Neurais e Deep Learning',
    author: 'I. Goodfellow',
    dueDate: '07/12',
    daysRemaining: 18,
    dueSoon: false,
    category: LibraryCategory.computing,
  ),
];

const demoCatalog = [
  CatalogBook(
    id: 'tanenbaum-redes',
    title: 'Redes de Computadores',
    author: 'A. Tanenbaum',
    edition: '6ª ed.',
    category: LibraryCategory.computing,
    availability: BookAvailability.available,
  ),
  CatalogBook(
    id: 'goodfellow-deep-learning',
    title: 'Redes Neurais e Deep Learning',
    author: 'I. Goodfellow',
    category: LibraryCategory.computing,
    availability: BookAvailability.borrowed,
  ),
  CatalogBook(
    id: 'kurose-redes',
    title: 'Redes de Computadores e a Internet',
    author: 'J. Kurose',
    edition: '8ª ed.',
    category: LibraryCategory.computing,
    availability: BookAvailability.available,
  ),
  CatalogBook(
    id: 'stallings-seguranca',
    title: 'Segurança de Redes',
    author: 'W. Stallings',
    category: LibraryCategory.computing,
    availability: BookAvailability.available,
  ),
  CatalogBook(
    id: 'cormen-algoritmos',
    title: 'Estruturas de Dados e Algoritmos',
    author: 'T. Cormen',
    category: LibraryCategory.computing,
    availability: BookAvailability.borrowed,
  ),
  CatalogBook(
    id: 'stewart-calculo',
    title: 'Cálculo · Volume 1',
    author: 'J. Stewart',
    edition: '8ª ed.',
    category: LibraryCategory.exact,
    availability: BookAvailability.available,
  ),
  CatalogBook(
    id: 'giddens-sociologia',
    title: 'Sociologia',
    author: 'A. Giddens',
    category: LibraryCategory.humanities,
    availability: BookAvailability.available,
  ),
  CatalogBook(
    id: 'revista-computacao',
    title: 'Revista de Computação Aplicada',
    author: 'Instituto Órbita',
    category: LibraryCategory.periodicals,
    availability: BookAvailability.available,
  ),
];
