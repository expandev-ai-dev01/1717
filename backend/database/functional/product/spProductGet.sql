/**
 * @summary
 * Retrieves the full details for a single product, including its images, available flavors, and sizes.
 * 
 * @procedure spProductGet
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/external/public/product/{id}
 * 
 * @parameters
 * @param {INT} idAccount 
 *   - Required: Yes
 *   - Description: The account identifier to scope the product search.
 * @param {INT} idProduct
 *   - Required: Yes
 *   - Description: The unique identifier of the product to retrieve.
 * 
 * @testScenarios
 * - Retrieve a valid, active product.
 * - Attempt to retrieve a product from another account (should return nothing).
 * - Attempt to retrieve a non-existent product (should return nothing).
 * - Retrieve a product with multiple images, flavors, and sizes.
 */
CREATE OR ALTER PROCEDURE [functional].[spProductGet]
    @idAccount INT,
    @idProduct INT
AS
BEGIN
    SET NOCOUNT ON;

    /**
     * @output {ProductDetails, 1, 1}
     * @column {INT} idProduct - Product's unique identifier.
     * @column {NVARCHAR(100)} name - Product's name.
     * @column {NVARCHAR(1000)} description - Detailed product description.
     * @column {NVARCHAR(MAX)} ingredientsJson - JSON array of ingredients.
     * @column {NUMERIC(18, 6)} basePrice - The base price of the product.
     * @column {NVARCHAR(50)} preparationTime - Estimated time for preparation.
     * @column {INT} idCategory - The identifier of the product's category.
     * @column {NVARCHAR(100)} categoryName - The name of the product's category.
     */
    SELECT
        [prd].[idProduct],
        [prd].[name],
        [prd].[description],
        [prd].[ingredientsJson],
        [prd].[basePrice],
        [prd].[preparationTime],
        [prd].[idCategory],
        [cat].[name] AS [categoryName]
    FROM [functional].[product] [prd]
    JOIN [functional].[category] [cat] ON ([cat].[idAccount] = [prd].[idAccount] AND [cat].[idCategory] = [prd].[idCategory])
    WHERE [prd].[idAccount] = @idAccount
      AND [prd].[idProduct] = @idProduct
      AND [prd].[deleted] = 0
      AND [prd].[active] = 1;

    /**
     * @output {ProductImages, n, n}
     * @column {INT} idProductImage - Image's unique identifier.
     * @column {NVARCHAR(2048)} imageUrl - The URL of the image.
     * @column {BIT} isPrimary - Flag indicating if it's the main image.
     */
    SELECT
        [img].[idProductImage],
        [img].[imageUrl],
        [img].[isPrimary]
    FROM [functional].[productImage] [img]
    WHERE [img].[idAccount] = @idAccount
      AND [img].[idProduct] = @idProduct
      AND [img].[deleted] = 0
    ORDER BY [img].[isPrimary] DESC;

    /**
     * @output {ProductFlavors, n, n}
     * @column {INT} idFlavor - Flavor's unique identifier.
     * @column {NVARCHAR(100)} name - The name of the flavor.
     */
    SELECT
        [flv].[idFlavor],
        [flv].[name]
    FROM [functional].[flavor] [flv]
    JOIN [functional].[product_flavor] [prdFlv] ON ([prdFlv].[idAccount] = [flv].[idAccount] AND [prdFlv].[idFlavor] = [flv].[idFlavor])
    WHERE [flv].[idAccount] = @idAccount
      AND [prdFlv].[idProduct] = @idProduct
      AND [flv].[deleted] = 0;

    /**
     * @output {ProductSizes, n, n}
     * @column {INT} idSize - Size's unique identifier.
     * @column {NVARCHAR(100)} name - The name of the size.
     * @column {NVARCHAR(255)} description - A user-friendly description of the size.
     * @column {NUMERIC(18, 6)} priceModifier - The additional cost for this size.
     */
    SELECT
        [siz].[idSize],
        [siz].[name],
        [siz].[description],
        [siz].[priceModifier]
    FROM [functional].[size] [siz]
    JOIN [functional].[product_size] [prdSiz] ON ([prdSiz].[idAccount] = [siz].[idAccount] AND [prdSiz].[idSize] = [siz].[idSize])
    WHERE [siz].[idAccount] = @idAccount
      AND [prdSiz].[idProduct] = @idProduct
      AND [siz].[deleted] = 0;

END;
GO
