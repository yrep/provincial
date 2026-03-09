<script lang="ts">
  import EntityContainer from './EntityContainer.svelte';
  import Pagination from './Pagination.svelte';

  interface Props<T> {
    items: T[];
    currentPage: number;
    totalPages: number;
    onPageChange: (page: number) => void;
    children: (item: T) => any;
  }

  let { items, currentPage, totalPages, onPageChange, children }: Props<any> = $props();
</script>

{#if items.length === 0}
  <p class="text-center text-gray-500 my-12">No items found.</p>
{:else}
  <EntityContainer>
    {#each items as item (item.id)}
      {@render children(item)}
    {/each}
  </EntityContainer>
  <Pagination {currentPage} {totalPages} {onPageChange} />
{/if}