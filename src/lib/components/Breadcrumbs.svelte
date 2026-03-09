<script lang="ts">
  import { page } from "$app/state";

  type Crumb = {
    label: string;
    href: string;
  };

  let crumbs = $derived(() => {
    const path = page.url.pathname;
    const segments = path.split('/').filter(Boolean);
    const items: Crumb[] = [{ label: 'Home', href: '/' }];

    let currentPath = '';
    for (const seg of segments) {
      currentPath += `/${seg}`;
      let label = seg.charAt(0).toUpperCase() + seg.slice(1);
      if (/^[a-z0-9]+$/.test(seg) && seg.length > 8) {
        label = 'Details';
      }
      items.push({ label, href: currentPath });
    }
    return items;
  });
</script>

<div class="text-sm breadcrumbs my-4">
  <ul>
    {#each crumbs() as crumb, i (crumb.href)}
      <li class={i === crumbs().length - 1 ? 'font-semibold' : ''}>
        {#if i < crumbs().length - 1}
          <a href={crumb.href} class="text-primary hover:underline">
            {#if i === 0}
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="w-4 h-4 mr-1 stroke-current inline">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
              </svg>
            {/if}
            {crumb.label}
          </a>
        {:else}
          <span>{crumb.label}</span>
        {/if}
      </li>
    {/each}
  </ul>
</div>