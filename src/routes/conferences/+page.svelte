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
  let filters = $state<{ country?: string; event_date?: string; upcoming?: boolean }>({});
  let availableCountries = $state<string[]>([]);



  async function loadAllCountries() {
    try {
      const data = await getConferences(1, 500);
      const uniqueCountries = [...new Set(data.items.map(i => i.country).filter(Boolean))].sort();
      availableCountries = uniqueCountries;
    } catch (e) {
      console.error('Failed to load countries', e);
    }
  }

  function parseDate(dateStr: string): Date {
    const months: Record<string, number> = {
      january: 0, february: 1, march: 2, april: 3, may: 4, june: 5,
      july: 6, august: 7, september: 8, october: 9, november: 10, december: 11
    };
    const parts = dateStr.split(' ');
    if (parts.length !== 3) return new Date(0);
    const day = parseInt(parts[0].replace(/\D/g, ''), 10);
    const month = months[parts[1].toLowerCase()];
    const year = parseInt(parts[2], 10);
    return new Date(year, month, day);
  }

  function isUpcoming(conf: Conference): boolean {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return parseDate(conf.event_date) >= today;
  }

  function matchesDate(conf: Conference, filterDateStr: string): boolean {
    const filterDate = new Date(filterDateStr);
    filterDate.setHours(0, 0, 0, 0);
    const confDate = parseDate(conf.event_date);
    confDate.setHours(0, 0, 0, 0);
    return confDate >= filterDate;
  }

  let displayedItems = $derived(() => {
    let result = items;
    if (filters.upcoming) {
      result = result.filter(isUpcoming);
    }
    if (filters.event_date) {
      result = result.filter(c => matchesDate(c, filters.event_date!));
    }
    return result;
  });

  async function loadConferences() {
    loading = true;
    try {
      const data = await getConferences(currentPage, 20, filters.country ? { country: filters.country } : undefined);
      items = data.items;
      totalPages = data.totalPages;
      // if (items.length > 0) {
      //   availableCountries = [...new Set(items.map(i => i.country).filter(Boolean))].sort();
      // }
    } catch (e) {
      console.error('Failed to load conferences', e);
    } finally {
      loading = false;
    }
  }








  function handleApply(newFilters: Record<string, any>) {
    filters = {
      country: newFilters.country || undefined,
      event_date: newFilters.event_date || undefined,
      upcoming: newFilters.upcoming || false
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
    { type: 'date', label: 'Event date', key: 'event_date' },
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
    items={displayedItems()}
    {currentPage}
    {totalPages}
    onPageChange={handlePageChange}
  >
    {#snippet children(item: Conference)}
      <ConferenceItem conference={item} />
    {/snippet}
  </EntityList>
{/if}