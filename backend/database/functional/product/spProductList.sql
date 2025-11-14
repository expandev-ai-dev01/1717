/**
 * @summary
 * Retrieves a paginated and filtered list of products for the public catalog.
 * Supports filtering by search term, categories, flavors, sizes, and price range.
 * Also supports sorting by various criteria.
 * 
 * @procedure spProductList
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/external/public/product
 * 
 * @parameters
 * @param {INT} idAccount 
 *   - Required: Yes
 *   - Description: The account identifier to scope the product search.
 * @param {INT} pageNumber
 *   - Required: Yes
 *   - Description: The current page number for pagination (1-based).
 * @param {INT} pageSize
 *   - Required: Yes
 *   - Description: The number of items to return per page.
 * @param {NVARCHAR(50)} sort
 *   - Required: No
 *   - Description: Sorting criteria. E.g., 'price_asc', 'price_desc', 'name_asc'.
 * @param {NVARCHAR(100)} searchTerm
 *   - Required: No
 *   - Description: A search term to filter products by name or description.
 * @param {NVARCHAR(MAX)} categoryIds
 *   - Required: No
 *   - Description: A comma-separated string of category IDs to filter by.
 * @param {NVARCHAR(MAX)} flavorIds
 *   - Required: No
 *   - Description: A comma-separated string of flavor IDs to filter by.
 * @param {NVARCHAR(MAX)} sizeIds
 *   - Required: No
 *   - Description: A comma-separated string of size IDs to filter by.
 * @param {NUMERIC(18, 6)} minPrice
 *   - Required: No
 *   - Description: The minimum price for the price range filter.
 * @param {NUMERIC(18, 6)} maxPrice
 *   - Required: No
 *   - Description: The maximum price for the price range filter.
 * 
 * @testScenarios
 * - List products with default pagination and no filters.
 * - Filter by a single category.
 * - Filter by multiple flavors and a price range.
 * - Search for a product by name.
 * - Sort products by price descending.
 * - Request a page number that is out of bounds (should return empty list).
 */
CREATE OR ALTER PROCEDURE [functional].[spProductList]
    @idAccount INT,
    @pageNumber INT = 1,
    @pageSize INT = 12,
    @sort NVARCHAR(50) = 'relevance',
    @searchTerm NVARCHAR(100) = NULL,
    @categoryIds NVARCHAR(MAX) = NULL,
    @flavorIds NVARCHAR(MAX) = NULL,
    @sizeIds NVARCHAR(MAX) = NULL,
    @minPrice NUMERIC(18, 6) = NULL,
    @maxPrice NUMERIC(18, 6) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SearchPattern NVARCHAR(110) = '%' + @searchTerm + '%';

    WITH [FilteredProducts] AS (
        SELECT DISTINCT
            [prd].[idProduct]
        FROM [functional].[product] [prd]
        WHERE [prd].[idAccount] = @idAccount
          AND [prd].[deleted] = 0
          AND [prd].[active] = 1
          -- Search Term Filter
          AND (@searchTerm IS NULL OR [prd].[name] LIKE @SearchPattern OR [prd].[description] LIKE @SearchPattern)
          -- Category Filter
          AND (@categoryIds IS NULL OR [prd].[idCategory] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@categoryIds, ',')))
          -- Price Filter
          AND (@minPrice IS NULL OR [prd].[basePrice] >= @minPrice)
          AND (@maxPrice IS NULL OR [prd].[basePrice] <= @maxPrice)
          -- Flavor Filter
          AND (@flavorIds IS NULL OR EXISTS (
              SELECT 1 FROM [functional].[product_flavor] [pf]
              WHERE [pf].[idAccount] = @idAccount
                AND [pf].[idProduct] = [prd].[idProduct]
                AND [pf].[idFlavor] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@flavorIds, ','))
          ))
          -- Size Filter
          AND (@sizeIds IS NULL OR EXISTS (
              SELECT 1 FROM [functional].[product_size] [ps]
              WHERE [ps].[idAccount] = @idAccount
                AND [ps].[idProduct] = [prd].[idProduct]
                AND [ps].[idSize] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@sizeIds, ','))
          ))
    ),
    [ProductData] AS (
        SELECT
            [prd].[idProduct],
            [prd].[name],
            [prd].[basePrice],
            [prd].[preparationTime],
            [img].[imageUrl] AS [primaryImageUrl]
            -- Add other fields needed for sorting if necessary, e.g., dateCreated
        FROM [functional].[product] [prd]
        JOIN [FilteredProducts] [fp] ON [fp].[idProduct] = [prd].[idProduct]
        LEFT JOIN [functional].[productImage] [img] ON [img].[idAccount] = [prd].[idAccount]
                                                   AND [img].[idProduct] = [prd].[idProduct]
                                                   AND [img].[isPrimary] = 1
                                                   AND [img].[deleted] = 0
    ),
    [TotalCount] AS (
        SELECT COUNT(*) AS [total] FROM [FilteredProducts]
    )

    /**
     * @output {ProductList, n, n}
     * @column {INT} idProduct - Product's unique identifier.
     * @column {NVARCHAR(100)} name - Product's name.
     * @column {NUMERIC(18, 6)} basePrice - The base price of the product.
     * @column {NVARCHAR(50)} preparationTime - Estimated time for preparation.
     * @column {NVARCHAR(2048)} primaryImageUrl - The URL of the primary product image.
     */
    SELECT
        [pd].*
    FROM [ProductData] [pd]
    ORDER BY
        CASE WHEN @sort = 'price_asc' THEN [pd].[basePrice] END ASC,
        CASE WHEN @sort = 'price_desc' THEN [pd].[basePrice] END DESC,
        CASE WHEN @sort = 'name_asc' THEN [pd].[name] END ASC,
        CASE WHEN @sort = 'name_desc' THEN [pd].[name] END DESC,
        -- Default sort by relevance (id)
        [pd].[idProduct] ASC
    OFFSET (@pageNumber - 1) * @pageSize ROWS
    FETCH NEXT @pageSize ROWS ONLY;

    /**
     * @output {Pagination, 1, 1}
     * @column {INT} total - The total number of products matching the filter criteria.
     */
    SELECT [total] FROM [TotalCount];

END;
GO
