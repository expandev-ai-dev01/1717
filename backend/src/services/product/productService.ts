import { IRecordSet } from 'mssql';
import { dbRequest, ExpectedReturn } from '@/utils/database/sql';
import { ProductListParams, ProductDetail, ProductListItem, Pagination } from './productTypes';

/**
 * @summary
 * Fetches a paginated list of products based on filter criteria.
 *
 * @param {ProductListParams} params - The filtering, sorting, and pagination parameters.
 * @returns {Promise<{ products: ProductListItem[]; pagination: Pagination }>} The list of products and pagination info.
 */
export async function listProducts(
  params: ProductListParams
): Promise<{ products: ProductListItem[]; pagination: Pagination }> {
  const dbParams = {
    idAccount: params.idAccount,
    pageNumber: params.page,
    pageSize: params.pageSize,
    sort: params.sort,
    searchTerm: params.search || null,
    categoryIds: params.categories?.join(',') || null,
    flavorIds: params.flavors?.join(',') || null,
    sizeIds: params.sizes?.join(',') || null,
    minPrice: params.priceMin || null,
    maxPrice: params.priceMax || null,
  };

  const result = (await dbRequest(
    '[functional].[spProductList]',
    dbParams,
    ExpectedReturn.Multi
  )) as IRecordSet<any>[];

  const products: ProductListItem[] = result[0];
  const totalRecords = result[1][0]?.total || 0;

  const pagination: Pagination = {
    currentPage: params.page,
    pageSize: params.pageSize,
    totalItems: totalRecords,
    totalPages: Math.ceil(totalRecords / params.pageSize),
  };

  return { products, pagination };
}

/**
 * @summary
 * Fetches the detailed information for a single product by its ID.
 *
 * @param {object} params - The parameters containing account and product IDs.
 * @param {number} params.idAccount - The account ID.
 * @param {number} params.idProduct - The product ID.
 * @returns {Promise<ProductDetail | null>} The detailed product object or null if not found.
 */
export async function getProductById(params: {
  idAccount: number;
  idProduct: number;
}): Promise<ProductDetail | null> {
  const result = await dbRequest(
    '[functional].[spProductGet]',
    params,
    ExpectedReturn.Multi,
    undefined,
    ['productDetails', 'images', 'flavors', 'sizes']
  );

  const productInfo = result.productDetails[0];

  if (!productInfo) {
    return null;
  }

  return {
    ...productInfo,
    ingredients: productInfo.ingredientsJson ? JSON.parse(productInfo.ingredientsJson) : [],
    images: result.images || [],
    flavors: result.flavors || [],
    sizes: result.sizes || [],
  };
}
