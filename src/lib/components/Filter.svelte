<script lang="ts">
  interface Props {
    countries?: string[];
    years?: number[];
    onFilter: (filters: { country: string; year: number | null }) => void;
  }

  let { countries = [], years = [], onFilter }: Props = $props();

  let selectedCountry = $state('');
  let selectedYear = $state<number | null>(null);

  function applyFilter() {
    onFilter({ country: selectedCountry, year: selectedYear });
  }

  function resetFilter() {
    selectedCountry = '';
    selectedYear = null;
    onFilter({ country: '', year: null });
  }
</script>

<div class="flex flex-wrap gap-4 items-end mb-6 p-4 bg-base-200 rounded-box">
  <label class="form-control w-full max-w-xs">
    <span class="label-text">Country</span>
    <select class="select select-bordered" bind:value={selectedCountry}>
      <option value="">All countries</option>
      {#each countries as country}
        <option value={country}>{country}</option>
      {/each}
    </select>
  </label>

  <label class="form-control w-full max-w-xs">
    <span class="label-text">Year founded</span>
    <select class="select select-bordered" bind:value={selectedYear}>
      <option value={null}>All years</option>
      {#each years as year}
        <option value={year}>{year}</option>
      {/each}
    </select>
  </label>

  <button class="btn btn-primary" onclick={applyFilter}>Apply</button>
  <button class="btn btn-ghost" onclick={resetFilter}>Reset</button>
</div>