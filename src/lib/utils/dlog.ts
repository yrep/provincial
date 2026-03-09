import { PUBLIC_DEBUG } from '$env/static/public';

export function dlog(...args: unknown[]): void {
  if (PUBLIC_DEBUG === 'true') {
    console.log('[DEBUG]', ...args);
  }
}
