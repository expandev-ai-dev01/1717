/**
 * @schema config
 * Contains system-wide configuration, settings, and utility objects.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'config')
BEGIN
    EXEC('CREATE SCHEMA [config]');
END;
GO
