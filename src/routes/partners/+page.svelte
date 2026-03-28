<script lang="ts">
  import { onMount } from 'svelte';
  import EntityList from '$lib/components/EntityList.svelte';
  import { getPartners } from '$lib/api/partners';
  import type { Partner } from '$lib/types';

  let items = $state<Partner[]>([]);
  let currentPage = $state(1);
  let totalPages = $state(0);
  let loading = $state(false);

  async function loadPartners() {
    loading = true;
    try {
      const data = await getPartners(currentPage, 21);
      items = data.items;
      totalPages = data.totalPages;
    } catch (e) {
      console.error('Failed to load partners', e);
    } finally {
      loading = false;
    }
  }

  function handlePageChange(page: number) {
    currentPage = page;
    loadPartners();
  }

  onMount(() => {
    loadPartners();
  });
</script>

<h1 class="text-3xl font-bold my-6">Partners</h1>

{#if loading}
  <div class="flex justify-center my-12">
    <span class="loading loading-spinner loading-lg"></span>
  </div>
{:else}
  <EntityList
    items={items}
    {currentPage}
    {totalPages}
    onPageChange={handlePageChange}
  >
    {#snippet children(item: Partner)}
      <div class="card bg-base-100 shadow-xl h-full flex flex-col">
        {#if item.image}
          <figure class="px-4 pt-4">
            <img src={item.image} alt={item.name} class="rounded-xl h-40 w-full object-cover" />
          </figure>
        {/if}
        <div class="card-body">
          <h5 class="card-title">{item.name}</h5>
          <p class="text-base-content/70">{item.type} • {item.country}</p>
          {#if item.summary}
            <p class="mt-2 text-sm line-clamp-3 text-base-content/80">{item.summary}</p>
          {/if}
          <div class="card-actions justify-end mt-4">
            <a href={item.link || '#'} class="btn btn-primary btn-sm" target="_blank">Learn more</a>
          </div>
        </div>
      </div>
    {/snippet}
  </EntityList>
{/if}