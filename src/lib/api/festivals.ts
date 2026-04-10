import { apiClient, apiGetById } from './client';
import type { Festival } from '$lib/types';

export async function getFestivals(
  page = 1,
  perPage = 20,
  filters?: {
    country?: string;
    startDateFrom?: string; // YYYY-MM-DD
    startDateTo?: string;   // YYYY-MM-DD
  }
) {
  const conditions: string[] = [];

  if (filters?.country) {
    conditions.push(`country = '${filters.country}'`);
  }
  if (filters?.startDateFrom) {
    conditions.push(`start_date >= '${filters.startDateFrom}'`);
  }
  if (filters?.startDateTo) {
    conditions.push(`start_date <= '${filters.startDateTo}'`);
  }

  const filter = conditions.length ? conditions.join(' && ') : undefined;
  return apiClient<Festival>('festivals', { page, perPage, filter });
}

export async function getFestivalById(id: string) {
  return apiGetById<Festival>('festivals', id);
}