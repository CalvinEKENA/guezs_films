export interface Property {
  id: string;
  title: string;
  location: string;
  price: number;
  type: 'Vente' | 'Location' | 'Promotion';
  surface: number;
  bedrooms: number;
  image: string;
  category: 'Luxe' | 'Standard' | 'Business';
}
