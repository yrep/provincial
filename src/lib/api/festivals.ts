import { apiClient, apiGetById } from './client';
import type { Festival } from '$lib/types';

export async function getFestivals(page = 1, perPage = 20, filters?: { country?: string; year?: number }) {
  let filter = '';
  if (filters?.country) {
    filter += `country = '${filters.country}'`;
  }
  if (filters?.year) {
    if (filter) filter += ' && ';
    filter += `year_founded = ${filters.year}`;
  }
  return apiClient<Festival>('festivals', { page, perPage, filter: filter || undefined });
}

export async function getFestivalById(id: string) {
  return apiGetById<Festival>('festivals', id);
}
