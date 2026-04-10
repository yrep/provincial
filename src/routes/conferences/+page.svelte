<script lang="ts">
  import { onMount } from 'svelte';
  import FilterBar from '$lib/components/FilterBar.svelte';
  import EntityList from '$lib/components/EntityList.svelte';
  import ConferenceItem from '$lib/components/ConferenceItem.svelte';
  import { getConferences } from '$lib/api/conferences';
  import type { Conference } from '$lib/types';

  let items = $state<Conference[]>([]);
  let currentPage = $state(1);
  let totalPages = $state(0);
  let loading = $state(false);
  let filters = $state<{ country?: string; startDateFrom?: string; startDateTo?: string; upcoming?: boolean }>({});
  let availableCountries = $state<string[]>([]);

  async function loadAllCountries() {
    try {
      // Загружаем все конференции без пагинации только для получения списка стран
      const data = await getConferences({ perPage: 500 });
      const uniqueCountries = [...new Set(data.items.map(i => i.country).filter(Boolean))].sort();
      availableCountries = uniqueCountries;
    } catch (e) {
      console.error('Failed to load countries', e);
    }
  }

  async function loadConferences() {
    loading = true;
    try {
      const params: Record<string, any> = {
        page: currentPage,
        perPage: 20,
      };
      if (filters.country) params.country = filters.country;
      if (filters.startDateFrom) params.startDateFrom = filters.startDateFrom;
      if (filters.startDateTo) params.startDateTo = filters.startDateTo;

      const data = await getConferences(params);
      items = data.items;
      totalPages = data.totalPages;
    } catch (e) {
      console.error('Failed to load conferences', e);
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
    loadConferences();
  }

  function handleReset() {
    filters = {};
    currentPage = 1;
    loadConferences();
  }

  function handlePageChange(page: number) {
    currentPage = page;
    loadConferences();
  }

  onMount(() => {
    loadAllCountries();
    loadConferences();
  });
</script>

<h1 class="text-3xl font-bold my-6">Conferences</h1>

<FilterBar
  fields={[
    { type: 'country', label: 'Country', key: 'country' },
    { type: 'dateRange', label: 'Start date', keyFrom: 'startDateFrom', keyTo: 'startDateTo' },
    { type: 'checkbox', label: 'Only upcoming', key: 'upcoming' }
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
    {#snippet children(item: Conference)}
      <ConferenceItem conference={item} />
    {/snippet}
  </EntityList>
{/if}