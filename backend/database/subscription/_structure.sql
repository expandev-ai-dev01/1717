/**
 * @schema subscription
 * Handles account management, subscription plans, and multi-tenancy root objects.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'subscription')
BEGIN
    EXEC('CREATE SCHEMA [subscription]');
END;
GO

/**
 * @table account Represents a tenant in the multi-tenant system.
 * @multitenancy false
 * @softDelete true
 * @alias acc
 */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[subscription].[account]') AND type in (N'U'))
BEGIN
CREATE TABLE [subscription].[account] (
  [idAccount] INTEGER IDENTITY(1, 1) NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
END;
GO

-- CONSTRAINTS
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID(N'[subscription].[account]'))
BEGIN
/**
 * @primaryKey pkAccount
 * @keyType Object
 */
ALTER TABLE [subscription].[account]
ADD CONSTRAINT [pkAccount] PRIMARY KEY CLUSTERED ([idAccount]);
END;
GO

IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfAccount_dateCreated')
BEGIN
ALTER TABLE [subscription].[account]
ADD CONSTRAINT [dfAccount_dateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
END;
GO

IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfAccount_dateModified')
BEGIN
ALTER TABLE [subscription].[account]
ADD CONSTRAINT [dfAccount_dateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
END;
GO

IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'dfAccount_deleted')
BEGIN
ALTER TABLE [subscription].[account]
ADD CONSTRAINT [dfAccount_deleted] DEFAULT (0) FOR [deleted];
END;
GO

-- INDEXES
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'uqAccount_Name' AND object_id = OBJECT_ID(N'[subscription].[account]'))
BEGIN
/**
 * @index uqAccount_Name Ensures account names are unique for active accounts.
 * @type Performance
 * @unique true
 * @filter Only includes non-deleted accounts.
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqAccount_Name]
ON [subscription].[account]([name])
WHERE [deleted] = 0;
END;
GO
