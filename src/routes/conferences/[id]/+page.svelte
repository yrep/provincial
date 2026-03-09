<script lang="ts">
  import { page } from "$app/state";
  import { onMount } from 'svelte';
  import { getConferenceById } from '$lib/api/conferences';
  import type { Conference } from '$lib/types';

  let conference = $state<Conference | null>(null);
  let loading = $state(true);

  onMount(async () => {
    const id = page.params.id;
    if (id) {
      try {
        conference = await getConferenceById(id);
      } catch (e) {
        console.error('Failed to load conference', e);
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
{:else if conference}
  <div class="card bg-base-100 shadow-xl max-w-4xl mx-auto my-8">
    <div class="card-body">
      <h1 class="text-3xl font-bold mb-4">{conference.event_name}</h1>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <p><span class="font-semibold">Date:</span> {conference.event_date}</p>
          <p><span class="font-semibold">Location:</span> {conference.city}, {conference.country}</p>
          {#if conference.organized}
            <p><span class="font-semibold">Organized by:</span> {conference.organized}</p>
          {/if}
        </div>
        <div>
          {#if conference.contact}
            <p><span class="font-semibold">Contact:</span> {conference.contact}</p>
          {/if}
          {#if conference.email}
            <p><span class="font-semibold">Email:</span> <a href="mailto:{conference.email}" class="link link-primary">{conference.email}</a></p>
          {/if}
          {#if conference.site}
            <p><span class="font-semibold">Website:</span> <a href={conference.site} target="_blank" class="link link-primary">{conference.site}</a></p>
          {/if}
          {#if conference.url}
            <p><span class="font-semibold">Event URL:</span> <a href={conference.url} target="_blank" class="link link-primary">{conference.url}</a></p>
          {/if}
        </div>
      </div>

      {#if conference.description}
        <div class="mt-6">
          <h2 class="text-xl font-semibold mb-2">Description</h2>
          <p class="whitespace-pre-line text-base-content/80">{conference.description}</p>
        </div>
      {/if}

      <div class="card-actions justify-start mt-8">
        <a href="/conferences" class="btn btn-primary">Back to conferences</a>
      </div>
    </div>
  </div>
{:else}
  <div class="alert alert-error max-w-md mx-auto my-12">
    <span>Conference not found.</span>
  </div>
{/if}