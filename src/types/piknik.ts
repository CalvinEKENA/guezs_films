export interface PiknikEvent {
  id: string;
  title: string;
  date: string;
  location: string;
  price: number;
  image: string;
  status: 'À venir' | 'Complet' | 'Passé';
  description: string;
}
