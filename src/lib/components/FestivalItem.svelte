<script lang="ts">
  import type { Festival } from '$lib/types';
  import DetailsButton from './DetailsButton.svelte';

  let { festival }: { festival: Festival } = $props();

  let imageError = $state(false);

  function handleImageError() {
    imageError = true;
  }

  function formatDate(dateStr?: string): string {
    if (!dateStr) return 'N/A';
    const date = new Date(dateStr);
    if (isNaN(date.getTime())) return 'N/A';
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    return `${day}.${month}.${year}`;
  }
</script>

<div class="card card-compact bg-base-100 shadow-xl w-full">
  <div class="flex flex-col md:flex-row gap-4 p-4">
    <div class="md:w-32 md:h-32 w-full flex-shrink-0">
      {#if !imageError && festival.logo_url}
        <img
          src={festival.logo_url}
          alt={festival.name}
          class="w-full h-full object-cover rounded-lg"
          onerror={handleImageError}
        />
      {:else}
        <div class="w-full h-full bg-base-300 rounded-lg flex items-center justify-center">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 text-base-content/50" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 4v16M17 4v16M3 8h18M3 16h18" />
          </svg>
        </div>
      {/if}
    </div>

    <div class="flex-1 flex flex-col">
      <h2 class="card-title line-clamp-2">{festival.name}</h2>
      <p class="text-base-content/70">
        {festival.country} • {festival.year_founded}
      </p>
      <p class="text-sm text-base-content/60">
        Event date: {formatDate(festival.start_date)}
      </p>
      <div class="card-actions justify-end mt-4">
        <DetailsButton href={`/festivals/${festival.id}`} />
      </div>
    </div>
  </div>
</div>