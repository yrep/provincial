import { apiClient, apiGetById } from './client';
import type { Conference } from '$lib/types';

export async function getConferences(page = 1, perPage = 20, filters?: { country?: string }) {
  let filter = '';
  if (filters?.country) {
    filter += `country = '${filters.country}'`;
  }
  return apiClient<Conference>('conferences', { page, perPage, filter: filter || undefined });
}

export async function getConferenceById(id: string) {
  return apiGetById<Conference>('conferences', id);
}