<script lang="ts">
  import Header from '$lib/components/Header.svelte';
  import Footer from '$lib/components/Footer.svelte';
  import Breadcrumbs from '$lib/components/Breadcrumbs.svelte';
  import favicon from '$lib/assets/favicon.svg';
  import '../app.css';

  let { children } = $props();
</script>

<svelte:head>
  <link rel="icon" href={favicon} />
</svelte:head>

<Header />
<main class="container mx-auto px-4 min-h-screen">
  <Breadcrumbs />
  {@render children()}
</main>
<Footer />
