/**
 * @schema security
 * Manages authentication, authorization, users, and other security-related objects.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'security')
BEGIN
    EXEC('CREATE SCHEMA [security]');
END;
GO
