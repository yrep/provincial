<script lang="ts">
  import { page } from "$app/state";
  
  let isMenuOpen = $state(false);
</script>

<div class="navbar bg-base-100 shadow-lg px-4">
  <div class="navbar-start">
    <a href="/" class="btn btn-ghost text-xl">
      <img src="/logo.png" alt="Provincial" class="h-6 w-6 mr-2" />
      Provincial
    </a>
  </div>
  
  <div class="navbar-center hidden lg:flex">
    <ul class="menu menu-horizontal px-1">
      <li><a href="/" class={page.url.pathname === '/' ? 'active' : ''}>Home</a></li>
      <li><a href="/services" class={page.url.pathname === '/services' ? 'active' : ''}>Services</a></li>
      <li><a href="/festivals" class={page.url.pathname.startsWith('/festivals') ? 'active' : ''}>Festivals</a></li>
      <li><a href="/conferences" class={page.url.pathname.startsWith('/conferences') ? 'active' : ''}>Conferences</a></li>
      <li><a href="/partners" class={page.url.pathname.startsWith('/partners') ? 'active' : ''}>Partners</a></li>
      <li><a href="/contacts" class={page.url.pathname === '/contacts' ? 'active' : ''}>Contacts</a></li>
    </ul>
  </div>
  
  <div class="navbar-end">
    <div class="dropdown dropdown-end">
      <button 
        class="btn btn-ghost lg:hidden" 
        onclick={() => isMenuOpen = !isMenuOpen}
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h8m-8 6h16" />
        </svg>
      </button>
      {#if isMenuOpen}
        <ul class="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52">
          <li><a href="/" class={page.url.pathname === '/' ? 'active' : ''}>Home</a></li>
          <li><a href="/services" class={page.url.pathname === '/services' ? 'active' : ''}>Services</a></li>
          <li><a href="/festivals" class={page.url.pathname.startsWith('/festivals') ? 'active' : ''}>Festivals</a></li>
          <li><a href="/conferences" class={page.url.pathname.startsWith('/conferences') ? 'active' : ''}>Conferences</a></li>
          <li><a href="/partners" class={page.url.pathname.startsWith('/partners') ? 'active' : ''}>Partners</a></li>
          <li><a href="/contacts" class={page.url.pathname === '/contacts' ? 'active' : ''}>Contacts</a></li>
        </ul>
      {/if}
    </div>
  </div>
</div>