import { apiClient } from './client';
import type { Partner } from '$lib/types';

export async function getPartners(page = 1, perPage = 20) {
  return apiClient<Partner>('partners', { page, perPage });
}
