import { z } from 'zod';
import { productListQuerySchema } from './productValidation';

// Base types from database
export interface Image {
  idProductImage: number;
  imageUrl: string;
  isPrimary: boolean;
}

export interface Flavor {
  idFlavor: number;
  name: string;
}

export interface Size {
  idSize: number;
  name: string;
  description: string;
  priceModifier: number;
}

// Type for the product card in the catalog list
export interface ProductListItem {
  idProduct: number;
  name: string;
  basePrice: number;
  preparationTime: string;
  primaryImageUrl: string | null;
}

// Type for the detailed product view
export interface ProductDetail {
  idProduct: number;
  name: string;
  description: string;
  ingredients: string[];
  basePrice: number;
  preparationTime: string;
  idCategory: number;
  categoryName: string;
  images: Image[];
  flavors: Flavor[];
  sizes: Size[];
}

// Type for pagination metadata
export interface Pagination {
  currentPage: number;
  pageSize: number;
  totalItems: number;
  totalPages: number;
}

// Type for the service layer function parameters, derived from Zod schema
export type ProductListParams = z.infer<typeof productListQuerySchema> & { idAccount: number };
