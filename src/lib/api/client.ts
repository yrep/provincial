import { PUBLIC_API_URL } from '$env/static/public';
import { dlog } from '$lib/utils/dlog';

interface ApiOptions {
  page?: number;
  perPage?: number;
  filter?: string;
}

export async function apiClient<T>(
  collection: string,
  options: ApiOptions = {}
): Promise<{ items: T[]; page: number; perPage: number; totalItems: number; totalPages: number }> {
  const url = new URL(`${PUBLIC_API_URL}/api/collections/${collection}/records`);
  if (options.page) url.searchParams.set('page', String(options.page));
  if (options.perPage) url.searchParams.set('perPage', String(options.perPage));
  if (options.filter) url.searchParams.set('filter', options.filter);

  dlog('Запрос:', url.toString());
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`API error: ${response.status}`);
  }
  const data = await response.json();
  dlog('Ответ:', data);
  return data;
}

export async function apiGetById<T>(collection: string, id: string): Promise<T> {
  const url = `${PUBLIC_API_URL}/api/collections/${collection}/records/${id}`;
  dlog('Запрос деталей:', url);
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`API error: ${response.status}`);
  }
  const data = await response.json();
  dlog('Ответ деталей:', data);
  return data;
}
