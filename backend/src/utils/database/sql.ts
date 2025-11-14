import sql, { IRecordSet, ConnectionPool, Transaction } from 'mssql';
import { config } from '@/config';
import { logger } from '@/utils/logger/logger';

export enum ExpectedReturn {
  Single,
  Multi,
  None,
}

let pool: ConnectionPool;

async function getPool(): Promise<ConnectionPool> {
  if (pool) {
    return pool;
  }
  try {
    pool = new ConnectionPool(config.database);
    await pool.connect();
    logger.info('Database connection pool established.');
    pool.on('error', (err) => {
      logger.error('Database pool error', err);
    });
    return pool;
  } catch (err) {
    logger.error('Failed to create database connection pool', err);
    process.exit(1);
  }
}

export async function dbRequest(
  routine: string,
  parameters: object,
  expectedReturn: ExpectedReturn,
  transaction?: Transaction,
  resultSetNames?: string[]
): Promise<any> {
  const connection = transaction || (await getPool());
  const request = connection.request();

  for (const key in parameters) {
    if (Object.prototype.hasOwnProperty.call(parameters, key)) {
      request.input(key, (parameters as any)[key]);
    }
  }

  const result = await request.execute(routine);

  switch (expectedReturn) {
    case ExpectedReturn.Single:
      return result.recordset[0] || null;
    case ExpectedReturn.Multi:
      if (resultSetNames && resultSetNames.length > 0) {
        const namedResultSets: { [key: string]: IRecordSet<any> } = {};
        resultSetNames.forEach((name, index) => {
          namedResultSets[name] = result.recordsets[index];
        });
        return namedResultSets;
      }
      return result.recordsets;
    case ExpectedReturn.None:
    default:
      return;
  }
}

export async function beginTransaction(): Promise<Transaction> {
  const pool = await getPool();
  return new Transaction(pool);
}

export async function commitTransaction(transaction: Transaction): Promise<void> {
  await transaction.commit();
}

export async function rollbackTransaction(transaction: Transaction): Promise<void> {
  await transaction.rollback();
}
