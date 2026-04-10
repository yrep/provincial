<script lang="ts">
  import type { Conference } from '$lib/types';
  import DetailsButton from './DetailsButton.svelte';

  let { conference }: { conference: Conference } = $props();

  function formatDate(dateStr?: string): string {
    if (!dateStr) return 'N/A';
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const date = new Date(dateStr);
    if (isNaN(date.getTime()) || date < today) return 'N/A';
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    return `${day}.${month}.${year}`;
  }
</script>

<div class="card bg-base-100 shadow-xl w-full">
  <div class="card-body">
    <h2 class="card-title">{conference.event_name}</h2>
    <p class="text-base-content/70">Event date: {formatDate(conference.start_date)}</p>
    <p class="text-sm">{conference.city}, {conference.country}</p>
    <div class="card-actions justify-end mt-4">
      <DetailsButton href={`/conferences/${conference.id}`} />
    </div>
  </div>
</div>