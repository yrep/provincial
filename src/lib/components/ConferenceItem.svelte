<script lang="ts">
  import type { Conference } from '$lib/types';
  import DetailsButton from './DetailsButton.svelte';

  let { conference }: { conference: Conference } = $props();
</script>

<div class="card bg-base-100 shadow-xl w-full">
  <div class="card-body">
    <h2 class="card-title">{conference.event_name}</h2>
    <p class="text-base-content/70">{conference.event_date}</p>
    <p class="text-sm">{conference.city}, {conference.country}</p>
    <div class="card-actions justify-end mt-4">
      <DetailsButton href={`/conferences/${conference.id}`} />
    </div>
  </div>
</div>