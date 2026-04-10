import { apiClient, apiGetById } from './client';
import type { Conference } from '$lib/types';

export async function getConferences(
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
  return apiClient<Conference>('conferences', { page, perPage, filter });
}

export async function getConferenceById(id: string) {
  return apiGetById<Conference>('conferences', id);
}