import { apiClient, apiGetById } from './client';
import type { Festival } from '$lib/types';

interface FestivalFilters {
  country?: string;
  startDateFrom?: string;
  startDateTo?: string;
}

export async function getFestivals(
  page = 1,
  perPage = 20,
  filters?: FestivalFilters,
  sort: string = 'start_date'
) {
  const conditions: string[] = [];

  if (filters?.country) conditions.push(`country = '${filters.country}'`);
  if (filters?.startDateFrom) conditions.push(`start_date >= '${filters.startDateFrom}'`);
  if (filters?.startDateTo) conditions.push(`start_date <= '${filters.startDateTo}'`);

  const filter = conditions.length > 0 ? conditions.join(' && ') : undefined;

  return apiClient<Festival>('festivals', { page, perPage, filter, sort });
}

export async function getFestivalById(id: string) {
  return apiGetById<Festival>('festivals', id);
}