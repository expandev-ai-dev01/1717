import { z } from 'zod';

const stringToNumberArray = z.string().transform((val, ctx) => {
  const ids = val.split(',').map((id) => parseInt(id.trim(), 10));
  if (ids.some(isNaN)) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'All IDs in the comma-separated list must be integers.',
    });
    return z.NEVER;
  }
  return ids;
});

export const productListQuerySchema = z
  .object({
    page: z.coerce.number().int().min(1).default(1),
    pageSize: z.coerce.number().int().min(1).max(36).default(12),
    sort: z
      .enum(['relevance', 'price_asc', 'price_desc', 'name_asc', 'name_desc'])
      .default('relevance'),
    search: z.string().max(100).optional(),
    categories: stringToNumberArray.optional(),
    flavors: stringToNumberArray.optional(),
    sizes: stringToNumberArray.optional(),
    priceMin: z.coerce.number().min(0).optional(),
    priceMax: z.coerce.number().positive().optional(),
  })
  .refine(
    (data) => {
      return !data.priceMax || !data.priceMin || data.priceMax > data.priceMin;
    },
    {
      message: 'priceMax must be greater than priceMin',
      path: ['priceMax'],
    }
  );
