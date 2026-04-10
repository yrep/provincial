<script lang="ts">
  import { page } from "$app/state";
  import { onMount } from 'svelte';
  import { getFestivalById } from '$lib/api/festivals';
  import type { Festival } from '$lib/types';

  let festival = $state<Festival | null>(null);
  let loading = $state(true);

  function formatDate(dateStr?: string): string {
    if (!dateStr) return 'N/A';
    const date = new Date(dateStr);
    if (isNaN(date.getTime())) return 'N/A';
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    return `${day}.${month}.${year}`;
  }

  onMount(async () => {
    const id = page.params.id;
    if (id) {
      try {
        festival = await getFestivalById(id);
      } catch (e) {
        console.error('Failed to load festival', e);
      } finally {
        loading = false;
      }
    }
  });
</script>

{#if loading}
  <div class="flex justify-center my-12">
    <span class="loading loading-spinner loading-lg"></span>
  </div>
{:else if festival}
  <div class="card bg-base-100 shadow-xl max-w-4xl mx-auto my-8">
    <div class="card-body">
      <h1 class="text-3xl font-bold mb-4">{festival.name}</h1>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        {#if festival.logo_url}
          <figure class="px-4 pt-4">
            <img src={festival.logo_url} alt={festival.name} class="rounded-xl" />
          </figure>
        {/if}
        <div class="md:col-span-2 space-y-4">
          <p><span class="font-semibold">Country:</span> {festival.country}</p>
          <p><span class="font-semibold">City:</span> {festival.city}</p>
          <p><span class="font-semibold">Founded:</span> {festival.year_founded}</p>
          <p><span class="font-semibold">Start date:</span> {formatDate(festival.start_date)}</p>
          {#if festival.website}
            <p><span class="font-semibold">Website:</span> <a href={festival.website} target="_blank" class="link link-primary">{festival.website}</a></p>
          {/if}
        </div>
      </div>
      
      {#if festival.about}
        <div class="mt-6">
          <h2 class="text-xl font-semibold mb-2">About</h2>
          <p class="whitespace-pre-line text-base-content/80">{festival.about}</p>
        </div>
      {/if}
      
      {#if festival.address}
        <div class="mt-6">
          <h2 class="text-xl font-semibold mb-2">Address</h2>
          <p class="whitespace-pre-line text-base-content/80">{festival.address}</p>
        </div>
      {/if}
      
      {#if festival.awards}
        <div class="mt-6">
          <h2 class="text-xl font-semibold mb-2">Awards</h2>
          <p class="whitespace-pre-line text-base-content/80">{festival.awards}</p>
        </div>
      {/if}
      
      {#if festival.rules}
        <div class="mt-6">
          <h2 class="text-xl font-semibold mb-2">Rules</h2>
          <p class="whitespace-pre-line text-base-content/80">{festival.rules}</p>
        </div>
      {/if}
      
      {#if festival.premiere_requirements}
        <div class="mt-6">
          <h2 class="text-xl font-semibold mb-2">Premiere Requirements</h2>
          <p class="text-base-content/80">{festival.premiere_requirements}</p>
        </div>
      {/if}
      
      <div class="card-actions justify-start mt-8">
        <a href="/festivals" class="btn btn-primary">Back to festivals</a>
      </div>
    </div>
  </div>
{:else}
  <div class="alert alert-error max-w-md mx-auto my-12">
    <span>Festival not found.</span>
  </div>
{/if}