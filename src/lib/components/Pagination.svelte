<script lang="ts">
  interface Props {
    currentPage: number;
    totalPages: number;
    onPageChange: (page: number) => void;
  }

  let { currentPage, totalPages, onPageChange }: Props = $props();

  function getPageNumbers() {
    if (totalPages <= 7) {
      // Если страниц мало, показываем все
      return Array.from({ length: totalPages }, (_, i) => i + 1);
    }

    const pages: (number | '...')[] = [];
    
    // Всегда показываем первую страницу
    pages.push(1);
    
    // Левая сторона
    if (currentPage > 3) {
      pages.push('...');
    }
    
    // Страницы вокруг текущей
    for (let i = Math.max(2, currentPage - 2); i <= Math.min(totalPages - 1, currentPage + 2); i++) {
      pages.push(i);
    }
    
    // Правая сторона
    if (currentPage < totalPages - 2) {
      pages.push('...');
    }
    
    // Всегда показываем последнюю страницу
    pages.push(totalPages);
    
    return pages;
  }

  let pages = $derived(getPageNumbers());
</script>

<div class="flex justify-center mt-8">
  <div class="join">
    <!-- Prev -->
    <button 
      class="join-item btn"
      class:btn-disabled={currentPage === 1}
      onclick={() => onPageChange(currentPage - 1)}
    >
      «
    </button>
    
    <!-- Page numbers -->
    {#each pages as page}
      {#if page === '...'}
        <button class="join-item btn btn-disabled">...</button>
      {:else}
        <button
          class="join-item btn"
          class:btn-active={page === currentPage}
          onclick={() => onPageChange(page)}
        >
          {page}
        </button>
      {/if}
    {/each}
    
    <!-- Next -->
    <button 
      class="join-item btn"
      class:btn-disabled={currentPage === totalPages}
      onclick={() => onPageChange(currentPage + 1)}
    >
      »
    </button>
  </div>
</div>