<script lang="ts">
  import { onMount } from 'svelte';

  type FilterField = {
    type: 'country' | 'year' | 'date' | 'checkbox';
    label: string;
    key: string;
    options?: any;
  };

  interface Props {
    fields: FilterField[];
    availableCountries?: string[];
    availableYears?: number[];
    onApply: (filters: Record<string, any>) => void;
    onReset: () => void;
    initialValues?: Record<string, any>;
  }

  let { fields, availableCountries = [], availableYears = [], onApply, onReset, initialValues = {} }: Props = $props();

  let values = $state<Record<string, any>>({});

  function initValues() {
    const newValues: Record<string, any> = {};
    fields.forEach(field => {
      if (field.key in initialValues) {
        newValues[field.key] = initialValues[field.key];
      } else {
        if (field.type === 'country' || field.type === 'year' || field.type === 'date') {
          newValues[field.key] = '';
        } else if (field.type === 'checkbox') {
          newValues[field.key] = false;
        }
      }
    });
    values = newValues;
  }

  $effect(() => {
    initValues();
  });

  let datePickerId = `date-${Math.random().toString(36).substring(2, 9)}`;

  function applyFilter() {
    const result: Record<string, any> = {};
    fields.forEach(field => {
      result[field.key] = values[field.key];
    });
    onApply(result);
  }

  function resetFilter() {
    initValues();
    onReset();
  }

  function handleDateChange(e: Event) {
    const target = e.target as HTMLElement & { value: string };
    values['event_date'] = target.value;
    const button = document.getElementById(datePickerId);
    if (button) {
      if (target.value) {
        const [year, month, day] = target.value.split('-');
        button.innerText = `${day}.${month}.${year}`;
      } else {
        button.innerText = 'Pick a date';
      }
    }
  }
</script>

<div class="flex flex-wrap gap-4 items-end mb-6 p-4 bg-base-200 rounded-box">
  {#each fields as field}
    {#if field.type === 'country'}
      <label class="form-control w-full max-w-xs">
        <span class="label-text">{field.label}</span>
        <select class="select select-bordered" bind:value={values[field.key]}>
          <option value="">All countries</option>
          {#each availableCountries as country}
            <option value={country}>{country}</option>
          {/each}
        </select>
      </label>
    {:else if field.type === 'year'}
      <label class="form-control w-full max-w-xs">
        <span class="label-text">{field.label}</span>
        <select class="select select-bordered" bind:value={values[field.key]}>
          <option value="">All years</option>
          {#each availableYears as year}
            <option value={year}>{year}</option>
          {/each}
        </select>
      </label>
    {:else if field.type === 'date'}
      <div class="form-control w-full max-w-xs">
        <span class="label-text">{field.label}</span>
        <button
          id={datePickerId}
          popovertarget="cally-popover"
          class="input input-bordered text-left"
          style="anchor-name:--cally"
        >
          {values[field.key] ? (() => {
            const [y, m, d] = values[field.key].split('-');
            return `${d}.${m}.${y}`;
          })() : 'Pick a date'}
        </button>
        <div
          popover
          id="cally-popover"
          class="dropdown bg-base-100 rounded-box shadow-lg"
          style="position-anchor:--cally"
        >
          <calendar-date class="cally" onchange={handleDateChange}>
            <svg aria-label="Previous" class="fill-current size-4" slot="previous" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M15.75 19.5 8.25 12l7.5-7.5"></path></svg>
            <svg aria-label="Next" class="fill-current size-4" slot="next" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m8.25 4.5 7.5 7.5-7.5 7.5"></path></svg>
            <calendar-month></calendar-month>
          </calendar-date>
        </div>
      </div>
    {:else if field.type === 'checkbox'}
      <label class="label cursor-pointer">
        <span class="label-text mr-2">{field.label}</span>
        <input type="checkbox" class="checkbox checkbox-primary" bind:checked={values[field.key]} />
      </label>
    {/if}
  {/each}

  <button class="btn btn-primary" onclick={applyFilter}>Apply</button>
  <button class="btn btn-ghost" onclick={resetFilter}>Reset</button>
</div>