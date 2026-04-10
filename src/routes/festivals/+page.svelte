<script lang="ts">
  import { onMount } from 'svelte';
  import FilterBar from '$lib/components/FilterBar.svelte';
  import EntityList from '$lib/components/EntityList.svelte';
  import FestivalItem from '$lib/components/FestivalItem.svelte';
  import { getFestivals } from '$lib/api/festivals';
  import type { Festival } from '$lib/types';

  let items = $state<Festival[]>([]);
  let currentPage = $state(1);
  let totalPages = $state(0);
  let loading = $state(false);
  let filters = $state<{
    country?: string;
    startDateFrom?: string;
    startDateTo?: string;
    upcoming?: boolean;
  }>({});
  let availableCountries = $state<string[]>([]);

  async function loadFestivals() {
    loading = true;
    try {
      const data = await getFestivals(currentPage, 20, {
        country: filters.country,
        startDateFrom: filters.startDateFrom,
        startDateTo: filters.startDateTo,
      });

      items = data.items;
      totalPages = data.totalPages;

      // Пополняем список стран при первой загрузке
      if (availableCountries.length === 0 && items.length > 0) {
        const countries = [...new Set(items.map(i => i.country).filter(Boolean))].sort();
        availableCountries = countries;
      }
    } catch (e) {
      console.error('Failed to load festivals', e);
    } finally {
      loading = false;
    }
  }

  function handleApply(newFilters: Record<string, any>) {
    filters = {
      country: newFilters.country,
      startDateFrom: newFilters.startDateFrom,
      startDateTo: newFilters.startDateTo,
      upcoming: newFilters.upcoming,
    };
    currentPage = 1;
    loadFestivals();
  }

  function handleReset() {
    filters = {};
    currentPage = 1;
    loadFestivals();
  }

  function handlePageChange(page: number) {
    currentPage = page;
    loadFestivals();
  }

  onMount(() => {
    loadFestivals();
  });
</script>

<h1 class="text-3xl font-bold my-6">Festivals</h1>

<FilterBar
  fields={[
    { type: 'country', label: 'Country', key: 'country' },
    { type: 'dateRange', label: 'Start date', keyFrom: 'startDateFrom', keyTo: 'startDateTo' },
    { type: 'checkbox', label: 'Only upcoming', key: 'upcoming' },
  ]}
  {availableCountries}
  onApply={handleApply}
  onReset={handleReset}
  initialValues={filters}
/>

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
    {#snippet children(item: Festival)}
      <FestivalItem festival={item} />
    {/snippet}
  </EntityList>
{/if}