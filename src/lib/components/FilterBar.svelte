<script lang="ts">
  import { onMount } from 'svelte';

  type FilterField = 
    | { type: 'country'; label: string; key: string }
    | { type: 'dateRange'; label: string; keyFrom: string; keyTo: string }
    | { type: 'checkbox'; label: string; key: string };

  interface Props {
    fields: FilterField[];
    availableCountries?: string[];
    onApply: (filters: Record<string, any>) => void;
    onReset: () => void;
    initialValues?: Record<string, any>;
  }

  let {
    fields,
    availableCountries = [],
    onApply,
    onReset,
    initialValues = {}
  }: Props = $props();

  // Локальное состояние фильтров
  let values = $state<Record<string, any>>({});

  // Инициализация значений из initialValues или значений по умолчанию
  function initValues() {
    const newValues: Record<string, any> = {};
    for (const field of fields) {
      if (field.type === 'country') {
        newValues[field.key] = initialValues[field.key] ?? '';
      } else if (field.type === 'dateRange') {
        newValues[field.keyFrom] = initialValues[field.keyFrom] ?? '';
        newValues[field.keyTo] = initialValues[field.keyTo] ?? '';
      } else if (field.type === 'checkbox') {
        newValues[field.key] = initialValues[field.key] ?? false;
      }
    }
    values = newValues;
  }

  // При изменении initialValues снаружи переинициализируем форму
  $effect(() => {
    initValues();
  });

  // Сегодняшняя дата в формате YYYY-MM-DD
  const today = $derived(new Date().toISOString().split('T')[0]);

  // Обработчик применения фильтров
  function applyFilter() {
    const result: Record<string, any> = {};
    for (const field of fields) {
      if (field.type === 'country') {
        result[field.key] = values[field.key] || undefined;
      } else if (field.type === 'dateRange') {
        result[field.keyFrom] = values[field.keyFrom] || undefined;
        result[field.keyTo] = values[field.keyTo] || undefined;
      } else if (field.type === 'checkbox') {
        result[field.key] = values[field.key] || false;
        // Если чекбокс "only upcoming", автоматически подставляем сегодня в dateFrom
        if (field.key === 'upcoming' && values[field.key]) {
          const dateRangeField = fields.find(f => f.type === 'dateRange');
          if (dateRangeField && dateRangeField.type === 'dateRange') {
            result[dateRangeField.keyFrom] = today;
          }
        }
      }
    }
    onApply(result);
  }

  function resetFilter() {
    initValues();
    onReset();
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
    {:else if field.type === 'dateRange'}
      <div class="form-control w-full max-w-xs">
        <span class="label-text">{field.label} (from → to)</span>
        <div class="flex gap-2">
          <input
            type="date"
            class="input input-bordered w-1/2"
            bind:value={values[field.keyFrom]}
            placeholder="From"
          />
          <input
            type="date"
            class="input input-bordered w-1/2"
            bind:value={values[field.keyTo]}
            placeholder="To"
          />
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