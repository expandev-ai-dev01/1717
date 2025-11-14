/**
 * @schema functional
 * Contains all business logic, entities, and operational objects for the application.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'functional')
BEGIN
    EXEC('CREATE SCHEMA [functional]');
END;
GO

/*
DROP TABLE [functional].[product_flavor];
DROP TABLE [functional].[product_size];
DROP TABLE [functional].[productImage];
DROP TABLE [functional].[product];
DROP TABLE [functional].[category];
DROP TABLE [functional].[flavor];
DROP TABLE [functional].[size];
*/

/**
 * @table category Represents product categories.
 * @multitenancy true
 * @softDelete true
 * @alias cat
 */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[functional].[category]') AND type in (N'U'))
BEGIN
CREATE TABLE [functional].[category] (
  [idCategory] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
END;
GO

/**
 * @table flavor Represents product flavors.
 * @multitenancy true
 * @softDelete true
 * @alias flv
 */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[functional].[flavor]') AND type in (N'U'))
BEGIN
CREATE TABLE [functional].[flavor] (
  [idFlavor] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
END;
GO

/**
 * @table size Represents product sizes.
 * @multitenancy true
 * @softDelete true
 * @alias siz
 */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[functional].[size]') AND type in (N'U'))
BEGIN
CREATE TABLE [functional].[size] (
  [idSize] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(255) NOT NULL,
  [priceModifier] NUMERIC(18, 6) NOT NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
END;
GO

/**
 * @table product Represents a cake or other product for sale.
 * @multitenancy true
 * @softDelete true
 * @alias prd
 */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[functional].[product]') AND type in (N'U'))
BEGIN
CREATE TABLE [functional].[product] (
  [idProduct] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idCategory] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(1000) NOT NULL,
  [ingredientsJson] NVARCHAR(MAX) NULL,
  [basePrice] NUMERIC(18, 6) NOT NULL,
  [preparationTime] NVARCHAR(50) NOT NULL,
  [active] BIT NOT NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
END;
GO

/**
 * @table productImage Stores images associated with a product.
 * @multitenancy true
 * @softDelete true
 * @alias prdImg
 */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[functional].[productImage]') AND type in (N'U'))
BEGIN
CREATE TABLE [functional].[productImage] (
  [idProductImage] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [imageUrl] NVARCHAR(2048) NOT NULL,
  [isPrimary] BIT NOT NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
END;
GO

/**
 * @table product_flavor Links products to available flavors.
 * @multitenancy true
 * @softDelete false
 * @alias prdFlv
 */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[functional].[product_flavor]') AND type in (N'U'))
BEGIN
CREATE TABLE [functional].[product_flavor] (
  [idAccount] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [idFlavor] INTEGER NOT NULL
);
END;
GO

/**
 * @table product_size Links products to available sizes.
 * @multitenancy true
 * @softDelete false
 * @alias prdSiz
 */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[functional].[product_size]') AND type in (N'U'))
BEGIN
CREATE TABLE [functional].[product_size] (
  [idAccount] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [idSize] INTEGER NOT NULL
);
END;
GO

-- CONSTRAINTS --

-- Category
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID(N'[functional].[category]'))
BEGIN
  /** @primaryKey pkCategory @keyType Object */
  ALTER TABLE [functional].[category] ADD CONSTRAINT [pkCategory] PRIMARY KEY CLUSTERED ([idCategory]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fkCategory_Account')
BEGIN
  /** @foreignKey fkCategory_Account Links category to an account. @target subscription.account */
  ALTER TABLE [functional].[category] ADD CONSTRAINT [fkCategory_Account] FOREIGN KEY ([idAccount]) REFERENCES [subscription].[account]([idAccount]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfCategory_deleted')
BEGIN
  ALTER TABLE [functional].[category] ADD CONSTRAINT [dfCategory_deleted] DEFAULT (0) FOR [deleted];
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfCategory_dateCreated')
BEGIN
  ALTER TABLE [functional].[category] ADD CONSTRAINT [dfCategory_dateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfCategory_dateModified')
BEGIN
  ALTER TABLE [functional].[category] ADD CONSTRAINT [dfCategory_dateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
END;
GO

-- Flavor
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID(N'[functional].[flavor]'))
BEGIN
  /** @primaryKey pkFlavor @keyType Object */
  ALTER TABLE [functional].[flavor] ADD CONSTRAINT [pkFlavor] PRIMARY KEY CLUSTERED ([idFlavor]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fkFlavor_Account')
BEGIN
  /** @foreignKey fkFlavor_Account Links flavor to an account. @target subscription.account */
  ALTER TABLE [functional].[flavor] ADD CONSTRAINT [fkFlavor_Account] FOREIGN KEY ([idAccount]) REFERENCES [subscription].[account]([idAccount]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfFlavor_deleted')
BEGIN
  ALTER TABLE [functional].[flavor] ADD CONSTRAINT [dfFlavor_deleted] DEFAULT (0) FOR [deleted];
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfFlavor_dateCreated')
BEGIN
  ALTER TABLE [functional].[flavor] ADD CONSTRAINT [dfFlavor_dateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfFlavor_dateModified')
BEGIN
  ALTER TABLE [functional].[flavor] ADD CONSTRAINT [dfFlavor_dateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
END;
GO

-- Size
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID(N'[functional].[size]'))
BEGIN
  /** @primaryKey pkSize @keyType Object */
  ALTER TABLE [functional].[size] ADD CONSTRAINT [pkSize] PRIMARY KEY CLUSTERED ([idSize]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fkSize_Account')
BEGIN
  /** @foreignKey fkSize_Account Links size to an account. @target subscription.account */
  ALTER TABLE [functional].[size] ADD CONSTRAINT [fkSize_Account] FOREIGN KEY ([idAccount]) REFERENCES [subscription].[account]([idAccount]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfSize_deleted')
BEGIN
  ALTER TABLE [functional].[size] ADD CONSTRAINT [dfSize_deleted] DEFAULT (0) FOR [deleted];
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfSize_dateCreated')
BEGIN
  ALTER TABLE [functional].[size] ADD CONSTRAINT [dfSize_dateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfSize_dateModified')
BEGIN
  ALTER TABLE [functional].[size] ADD CONSTRAINT [dfSize_dateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
END;
GO

-- Product
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID(N'[functional].[product]'))
BEGIN
  /** @primaryKey pkProduct @keyType Object */
  ALTER TABLE [functional].[product] ADD CONSTRAINT [pkProduct] PRIMARY KEY CLUSTERED ([idProduct]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fkProduct_Account')
BEGIN
  /** @foreignKey fkProduct_Account Links product to an account. @target subscription.account */
  ALTER TABLE [functional].[product] ADD CONSTRAINT [fkProduct_Account] FOREIGN KEY ([idAccount]) REFERENCES [subscription].[account]([idAccount]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fkProduct_Category')
BEGIN
  /** @foreignKey fkProduct_Category Links product to a category. @target functional.category */
  ALTER TABLE [functional].[product] ADD CONSTRAINT [fkProduct_Category] FOREIGN KEY ([idCategory]) REFERENCES [functional].[category]([idCategory]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfProduct_active')
BEGIN
  ALTER TABLE [functional].[product] ADD CONSTRAINT [dfProduct_active] DEFAULT (1) FOR [active];
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfProduct_deleted')
BEGIN
  ALTER TABLE [functional].[product] ADD CONSTRAINT [dfProduct_deleted] DEFAULT (0) FOR [deleted];
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfProduct_dateCreated')
BEGIN
  ALTER TABLE [functional].[product] ADD CONSTRAINT [dfProduct_dateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfProduct_dateModified')
BEGIN
  ALTER TABLE [functional].[product] ADD CONSTRAINT [dfProduct_dateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
END;
GO

-- ProductImage
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID(N'[functional].[productImage]'))
BEGIN
  /** @primaryKey pkProductImage @keyType Object */
  ALTER TABLE [functional].[productImage] ADD CONSTRAINT [pkProductImage] PRIMARY KEY CLUSTERED ([idProductImage]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fkProductImage_Account')
BEGIN
  /** @foreignKey fkProductImage_Account Links image to an account. @target subscription.account */
  ALTER TABLE [functional].[productImage] ADD CONSTRAINT [fkProductImage_Account] FOREIGN KEY ([idAccount]) REFERENCES [subscription].[account]([idAccount]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fkProductImage_Product')
BEGIN
  /** @foreignKey fkProductImage_Product Links image to a product. @target functional.product */
  ALTER TABLE [functional].[productImage] ADD CONSTRAINT [fkProductImage_Product] FOREIGN KEY ([idProduct]) REFERENCES [functional].[product]([idProduct]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfProductImage_isPrimary')
BEGIN
  ALTER TABLE [functional].[productImage] ADD CONSTRAINT [dfProductImage_isPrimary] DEFAULT (0) FOR [isPrimary];
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfProductImage_deleted')
BEGIN
  ALTER TABLE [functional].[productImage] ADD CONSTRAINT [dfProductImage_deleted] DEFAULT (0) FOR [deleted];
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfProductImage_dateCreated')
BEGIN
  ALTER TABLE [functional].[productImage] ADD CONSTRAINT [dfProductImage_dateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
END;
GO
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfProductImage_dateModified')
BEGIN
  ALTER TABLE [functional].[productImage] ADD CONSTRAINT [dfProductImage_dateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
END;
GO

-- Product_Flavor
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID(N'[functional].[product_flavor]'))
BEGIN
  /** @primaryKey pkProductFlavor @keyType Relationship */
  ALTER TABLE [functional].[product_flavor] ADD CONSTRAINT [pkProductFlavor] PRIMARY KEY CLUSTERED ([idAccount], [idProduct], [idFlavor]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fkProductFlavor_Product')
BEGIN
  /** @foreignKey fkProductFlavor_Product Links to product. @target functional.product */
  ALTER TABLE [functional].[product_flavor] ADD CONSTRAINT [fkProductFlavor_Product] FOREIGN KEY ([idProduct]) REFERENCES [functional].[product]([idProduct]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fkProductFlavor_Flavor')
BEGIN
  /** @foreignKey fkProductFlavor_Flavor Links to flavor. @target functional.flavor */
  ALTER TABLE [functional].[product_flavor] ADD CONSTRAINT [fkProductFlavor_Flavor] FOREIGN KEY ([idFlavor]) REFERENCES [functional].[flavor]([idFlavor]);
END;
GO

-- Product_Size
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID(N'[functional].[product_size]'))
BEGIN
  /** @primaryKey pkProductSize @keyType Relationship */
  ALTER TABLE [functional].[product_size] ADD CONSTRAINT [pkProductSize] PRIMARY KEY CLUSTERED ([idAccount], [idProduct], [idSize]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fkProductSize_Product')
BEGIN
  /** @foreignKey fkProductSize_Product Links to product. @target functional.product */
  ALTER TABLE [functional].[product_size] ADD CONSTRAINT [fkProductSize_Product] FOREIGN KEY ([idProduct]) REFERENCES [functional].[product]([idProduct]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fkProductSize_Size')
BEGIN
  /** @foreignKey fkProductSize_Size Links to size. @target functional.size */
  ALTER TABLE [functional].[product_size] ADD CONSTRAINT [fkProductSize_Size] FOREIGN KEY ([idSize]) REFERENCES [functional].[size]([idSize]);
END;
GO

-- INDEXES --

-- Category
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'ixCategory_Account' AND object_id = OBJECT_ID(N'[functional].[category]'))
BEGIN
  /** @index ixCategory_Account @type ForeignKey */
  CREATE NONCLUSTERED INDEX [ixCategory_Account] ON [functional].[category]([idAccount]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'uqCategory_Account_Name' AND object_id = OBJECT_ID(N'[functional].[category]'))
BEGIN
  /** @index uqCategory_Account_Name @type Search @unique true */
  CREATE UNIQUE NONCLUSTERED INDEX [uqCategory_Account_Name] ON [functional].[category]([idAccount], [name]) WHERE [deleted] = 0;
END;
GO

-- Flavor
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'ixFlavor_Account' AND object_id = OBJECT_ID(N'[functional].[flavor]'))
BEGIN
  /** @index ixFlavor_Account @type ForeignKey */
  CREATE NONCLUSTERED INDEX [ixFlavor_Account] ON [functional].[flavor]([idAccount]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'uqFlavor_Account_Name' AND object_id = OBJECT_ID(N'[functional].[flavor]'))
BEGIN
  /** @index uqFlavor_Account_Name @type Search @unique true */
  CREATE UNIQUE NONCLUSTERED INDEX [uqFlavor_Account_Name] ON [functional].[flavor]([idAccount], [name]) WHERE [deleted] = 0;
END;
GO

-- Size
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'ixSize_Account' AND object_id = OBJECT_ID(N'[functional].[size]'))
BEGIN
  /** @index ixSize_Account @type ForeignKey */
  CREATE NONCLUSTERED INDEX [ixSize_Account] ON [functional].[size]([idAccount]);
END;
GO

-- Product
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'ixProduct_Account' AND object_id = OBJECT_ID(N'[functional].[product]'))
BEGIN
  /** @index ixProduct_Account @type ForeignKey */
  CREATE NONCLUSTERED INDEX [ixProduct_Account] ON [functional].[product]([idAccount]);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'ixProduct_Account_Category' AND object_id = OBJECT_ID(N'[functional].[product]'))
BEGIN
  /** @index ixProduct_Account_Category @type ForeignKey */
  CREATE NONCLUSTERED INDEX [ixProduct_Account_Category] ON [functional].[product]([idAccount], [idCategory]) WHERE [deleted] = 0;
END;
GO

-- ProductImage
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'ixProductImage_Account_Product' AND object_id = OBJECT_ID(N'[functional].[productImage]'))
BEGIN
  /** @index ixProductImage_Account_Product @type ForeignKey */
  CREATE NONCLUSTERED INDEX [ixProductImage_Account_Product] ON [functional].[productImage]([idAccount], [idProduct]) WHERE [deleted] = 0;
END;
GO
