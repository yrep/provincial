#!/bin/bash

# Скрипт для генерации полной структуры проекта Provincial frontend
# Предполагается, что скрипт запускается из корня проекта (папка front)
# Используется pnpm, Tailwind CSS v4 (через @tailwindcss/vite)

set -e  # exit on error

echo "🚀 Начинаем генерацию файлов проекта Provincial frontend..."

# 1. Создаём необходимые папки
mkdir -p src/lib/api
mkdir -p src/lib/components
mkdir -p src/lib/utils
mkdir -p src/routes/services
mkdir -p src/routes/festivals/[id]
mkdir -p src/routes/conferences
mkdir -p src/routes/partners
mkdir -p src/routes/contacts
mkdir -p static

# 2. Создаём .env
cat > .env << 'EOF'
PUBLIC_API_URL=http://127.0.0.1:8090
PUBLIC_DEBUG=true
EOF

# 3. Создаём dlog.ts
cat > src/lib/utils/dlog.ts << 'EOF'
import { PUBLIC_DEBUG } from '$env/static/public';

export function dlog(...args: unknown[]): void {
  if (PUBLIC_DEBUG === 'true') {
    console.log('[DEBUG]', ...args);
  }
}
EOF

# 4. Создаём API клиент
cat > src/lib/api/client.ts << 'EOF'
import { PUBLIC_API_URL } from '$env/static/public';
import { dlog } from '$lib/utils/dlog';

interface ApiOptions {
  page?: number;
  perPage?: number;
  filter?: string;
}

export async function apiClient<T>(
  collection: string,
  options: ApiOptions = {}
): Promise<{ items: T[]; page: number; perPage: number; totalItems: number; totalPages: number }> {
  const url = new URL(`${PUBLIC_API_URL}/api/collections/${collection}/records`);
  if (options.page) url.searchParams.set('page', String(options.page));
  if (options.perPage) url.searchParams.set('perPage', String(options.perPage));
  if (options.filter) url.searchParams.set('filter', options.filter);

  dlog('Запрос:', url.toString());
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`API error: ${response.status}`);
  }
  const data = await response.json();
  dlog('Ответ:', data);
  return data;
}

export async function apiGetById<T>(collection: string, id: string): Promise<T> {
  const url = `${PUBLIC_API_URL}/api/collections/${collection}/records/${id}`;
  dlog('Запрос деталей:', url);
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`API error: ${response.status}`);
  }
  const data = await response.json();
  dlog('Ответ деталей:', data);
  return data;
}
EOF

# 5. festivals.ts
cat > src/lib/api/festivals.ts << 'EOF'
import { apiClient, apiGetById } from './client';
import type { Festival } from '$lib/types';

export async function getFestivals(page = 1, perPage = 20, filters?: { country?: string; year?: number }) {
  let filter = '';
  if (filters?.country) {
    filter += `country = '${filters.country}'`;
  }
  if (filters?.year) {
    if (filter) filter += ' && ';
    filter += `year_founded = ${filters.year}`;
  }
  return apiClient<Festival>('festivals', { page, perPage, filter: filter || undefined });
}

export async function getFestivalById(id: string) {
  return apiGetById<Festival>('festivals', id);
}
EOF

# 6. partners.ts
cat > src/lib/api/partners.ts << 'EOF'
import { apiClient } from './client';
import type { Partner } from '$lib/types';

export async function getPartners(page = 1, perPage = 20) {
  return apiClient<Partner>('partners', { page, perPage });
}
EOF

# 7. conferences.ts (заглушка)
cat > src/lib/api/conferences.ts << 'EOF'
import { apiClient, apiGetById } from './client';
import type { Conference } from '$lib/types';

export async function getConferences(page = 1, perPage = 20) {
  return {
    items: [] as Conference[],
    page,
    perPage,
    totalItems: 0,
    totalPages: 0
  };
}

export async function getConferenceById(id: string): Promise<Conference | null> {
  return null;
}
EOF

# 8. types.ts
cat > src/lib/types.ts << 'EOF'
export interface Festival {
  id: string;
  name: string;
  country: string;
  year_founded: number;
  about?: string;
  address?: string;
  awards?: string;
  city?: string;
  logo_url?: string;
  premiere_requirements?: string;
  rules?: string;
  short_description?: string;
  slug?: string;
  website?: string;
}

export interface Partner {
  id: string;
  name: string;
  type: string;
  country: string;
  city?: string;
  description?: string;
  summary?: string;
  image?: string;
  link?: string;
}

export interface Conference {
  id: string;
  name: string;
  country: string;
  year: number;
}
EOF

# 9. Header.svelte
cat > src/lib/components/Header.svelte << 'EOF'
<script lang="ts">
  import { Navbar, NavBrand, NavHamburger, NavLi, NavUl } from 'flowbite-svelte';
  import { page } from '$app/stores';

  let { isMenuOpen = $state(false) } = $props();
</script>

<Navbar let:children class="px-4 py-2 bg-white shadow">
  <NavBrand href="/">
    <img src="/logo.svg" alt="Provincial" class="h-8" />
    <span class="self-center text-xl font-semibold whitespace-nowrap">Provincial</span>
  </NavBrand>
  <NavHamburger on:click={() => (isMenuOpen = !isMenuOpen)} />
  <NavUl {isMenuOpen} class="md:flex md:space-x-8">
    <NavLi href="/" active={$page.url.pathname === '/'}>Home</NavLi>
    <NavLi href="/services" active={$page.url.pathname === '/services'}>Services</NavLi>
    <NavLi href="/festivals" active={$page.url.pathname.startsWith('/festivals')}>Festivals</NavLi>
    <NavLi href="/conferences" active={$page.url.pathname.startsWith('/conferences')}>Conferences</NavLi>
    <NavLi href="/partners" active={$page.url.pathname.startsWith('/partners')}>Partners</NavLi>
    <NavLi href="/contacts" active={$page.url.pathname === '/contacts'}>Contacts</NavLi>
  </NavUl>
</Navbar>
EOF

# 10. Footer.svelte
cat > src/lib/components/Footer.svelte << 'EOF'
<script lang="ts">
  import { Footer, FooterBrand, FooterCopyright, FooterLink, FooterLinkGroup } from 'flowbite-svelte';
</script>

<Footer footerClass="bg-white rounded-lg shadow p-4 mt-8">
  <div class="w-full max-w-screen-xl mx-auto">
    <div class="grid grid-cols-2 gap-8 px-4 py-6 lg:py-8 md:grid-cols-4">
      <div>
        <h2 class="mb-6 text-sm font-semibold text-gray-900 uppercase">Company</h2>
        <FooterLinkGroup>
          <FooterLink href="/">Home</FooterLink>
          <FooterLink href="/services">Services</FooterLink>
          <FooterLink href="/contacts">Contacts</FooterLink>
        </FooterLinkGroup>
      </div>
      <div>
        <h2 class="mb-6 text-sm font-semibold text-gray-900 uppercase">Catalog</h2>
        <FooterLinkGroup>
          <FooterLink href="/festivals">Festivals</FooterLink>
          <FooterLink href="/conferences">Conferences</FooterLink>
          <FooterLink href="/partners">Partners</FooterLink>
        </FooterLinkGroup>
      </div>
      <div>
        <h2 class="mb-6 text-sm font-semibold text-gray-900 uppercase">Legal</h2>
        <FooterLinkGroup>
          <FooterLink href="#">Privacy Policy</FooterLink>
          <FooterLink href="#">Terms & Conditions</FooterLink>
        </FooterLinkGroup>
      </div>
      <div>
        <h2 class="mb-6 text-sm font-semibold text-gray-900 uppercase">Contact</h2>
        <div class="text-gray-600">
          <p>Provincial s.r.o. (ID: 19287321)</p>
          <p>Jaltska 1107/14, 360 01 Karlovy Vary</p>
          <p>Czech Republic</p>
          <p>Email: info@aparteu.com</p>
          <p>Phone: +420 607 191 489</p>
        </div>
      </div>
    </div>
    <div class="px-4 py-6 bg-gray-100 rounded-md">
      <FooterCopyright href="#" by="Provincial s.r.o." year={new Date().getFullYear()} />
    </div>
  </div>
</Footer>
EOF

# 11. Breadcrumbs.svelte
cat > src/lib/components/Breadcrumbs.svelte << 'EOF'
<script lang="ts">
  import { Breadcrumb, BreadcrumbItem } from 'flowbite-svelte';
  import { page } from '$app/stores';

  type Crumb = {
    label: string;
    href?: string;
  };

  let crumbs = $derived(() => {
    const path = $page.url.pathname;
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

<Breadcrumb aria-label="breadcrumb" class="my-4">
  {#each crumbs() as crumb, i}
    <BreadcrumbItem href={crumb.href} home={i === 0}>
      {crumb.label}
    </BreadcrumbItem>
  {/each}
</Breadcrumb>
EOF

# 12. Filter.svelte
cat > src/lib/components/Filter.svelte << 'EOF'
<script lang="ts">
  import { Label, Select, Button } from 'flowbite-svelte';

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

<div class="flex flex-wrap gap-4 items-end mb-6 p-4 bg-gray-50 rounded-lg">
  <div>
    <Label for="country">Country</Label>
    <Select id="country" bind:value={selectedCountry} class="mt-1">
      <option value="">All countries</option>
      {#each countries as country}
        <option value={country}>{country}</option>
      {/each}
    </Select>
  </div>
  <div>
    <Label for="year">Year founded</Label>
    <Select id="year" bind:value={selectedYear} class="mt-1">
      <option value={null}>All years</option>
      {#each years as year}
        <option value={year}>{year}</option>
      {/each}
    </Select>
  </div>
  <Button on:click={applyFilter} size="sm">Apply</Button>
  <Button on:click={resetFilter} size="sm" color="alternative">Reset</Button>
</div>
EOF

# 13. EntityContainer.svelte
cat > src/lib/components/EntityContainer.svelte << 'EOF'
<script lang="ts">
  let { children }: { children: any } = $props();
</script>

<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  {@render children()}
</div>
EOF

# 14. FestivalItem.svelte
cat > src/lib/components/FestivalItem.svelte << 'EOF'
<script lang="ts">
  import { Card } from 'flowbite-svelte';
  import type { Festival } from '$lib/types';
  import DetailsButton from './DetailsButton.svelte';

  let { festival }: { festival: Festival } = $props();
</script>

<Card class="h-full flex flex-col">
  <h5 class="text-xl font-bold tracking-tight text-gray-900 line-clamp-2">
    {festival.name}
  </h5>
  <p class="text-gray-600 mt-2">
    {festival.country} • {festival.year_founded}
  </p>
  <div class="mt-4">
    <DetailsButton href={`/festivals/${festival.id}`} />
  </div>
</Card>
EOF

# 15. DetailsButton.svelte
cat > src/lib/components/DetailsButton.svelte << 'EOF'
<script lang="ts">
  import { Button } from 'flowbite-svelte';

  let { href }: { href: string } = $props();
</script>

<Button href={href} size="sm">Details</Button>
EOF

# 16. Pagination.svelte
cat > src/lib/components/Pagination.svelte << 'EOF'
<script lang="ts">
  import { PaginationNav } from 'flowbite-svelte';
  import { onMount } from 'svelte';

  interface Props {
    currentPage: number;
    totalPages: number;
    onPageChange: (page: number) => void;
  }

  let { currentPage, totalPages, onPageChange }: Props = $props();

  let isMobile = $state(false);

  function checkMobile() {
    if (typeof window !== 'undefined') {
      isMobile = window.innerWidth <= 640;
    }
  }

  onMount(() => {
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  });
</script>

<div class="flex justify-center mt-8">
  <PaginationNav
    {currentPage}
    {totalPages}
    onPageChange={onPageChange}
    visiblePages={isMobile ? 3 : 7}
  />
</div>
EOF

# 17. EntityList.svelte
cat > src/lib/components/EntityList.svelte << 'EOF'
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
EOF

# 18. +layout.svelte (перезапись с импортом layout.css)
cat > src/routes/+layout.svelte << 'EOF'
<script lang="ts">
  import './layout.css';
  import Header from '$lib/components/Header.svelte';
  import Footer from '$lib/components/Footer.svelte';
  import Breadcrumbs from '$lib/components/Breadcrumbs.svelte';
  import favicon from '$lib/assets/favicon.svg';

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
EOF

# 19. +page.svelte (главная)
cat > src/routes/+page.svelte << 'EOF'
<script lang="ts">
  import { Button } from 'flowbite-svelte';
</script>

<section class="bg-gradient-to-r from-blue-600 to-indigo-700 text-white py-20 rounded-lg my-8">
  <div class="container mx-auto px-4 text-center">
    <h1 class="text-4xl md:text-5xl font-bold mb-4">Elevating Independent Voices Across Every Screen and Stage.</h1>
    <p class="text-xl mb-8 max-w-3xl mx-auto">
      Specialized in the global distribution of fiction, docs, VR, and experimental film. Beyond the screen, we bridge the gap for cultural conferences, independent musicians, and visual artists through professional subtitles, bespoke design, and strategic sponsorship support.
    </p>
    <Button href="/services" size="lg" color="light">Our Services</Button>
  </div>
</section>

<section class="my-12">
  <div class="bg-white p-8 rounded-lg shadow">
    <h2 class="text-3xl font-bold mb-4">About</h2>
    <p class="text-gray-700 leading-relaxed">
      Based in Karlovy Vary, Provincial s.r.o. provides distribution and promotional infrastructure for independent creators. We simplify the path to international recognition for filmmakers, artists, and cultural organizations, allowing them to focus on their creative work while we handle the logistics of global exposure.
    </p>
    <p class="text-gray-700 leading-relaxed mt-4">
      Our core expertise lies in festival distribution. We represent fiction, documentaries, VR, and experimental projects, ensuring they reach the right programmers without requiring creators to surrender their rights. To support a successful premiere, we provide full technical and creative support, including professional subtitling and the design of all promotional materials—from posters to social media kits.
    </p>
    <p class="text-gray-700 leading-relaxed mt-4">
      Beyond cinema, Provincial s.r.o. actively supports the broader cultural ecosystem. We organize art exhibitions, promote international conferences, and facilitate sponsorships for independent musicians and performers.
    </p>
  </div>
</section>

<section class="my-12">
  <h2 class="text-3xl font-bold mb-6">Services</h2>
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
    <div class="bg-white p-6 rounded-lg shadow">
      <h3 class="text-xl font-semibold mb-2">Film Promotion</h3>
      <p class="text-gray-600">End-to-end festival strategy for shorts and features.</p>
    </div>
    <div class="bg-white p-6 rounded-lg shadow">
      <h3 class="text-xl font-semibold mb-2">Creative Services</h3>
      <p class="text-gray-600">Professional translation, subtitling, and visual branding.</p>
    </div>
    <div class="bg-white p-6 rounded-lg shadow">
      <h3 class="text-xl font-semibold mb-2">Cultural Support</h3>
      <p class="text-gray-600">Event organization and sponsorship for independent artists and musicians.</p>
    </div>
    <div class="bg-white p-6 rounded-lg shadow">
      <h3 class="text-xl font-semibold mb-2">Consultancy</h3>
      <p class="text-gray-600">Managing logistics for speakers and performers at international cultural events.</p>
    </div>
  </div>
</section>
EOF

# 20. services/+page.svelte
cat > src/routes/services/+page.svelte << 'EOF'
<script lang="ts">
  import { Card } from 'flowbite-svelte';
</script>

<h1 class="text-3xl font-bold my-6">Our Services</h1>

<div class="grid grid-cols-1 md:grid-cols-2 gap-8">
  <Card class="p-6">
    <h2 class="text-2xl font-bold mb-3">Film Promotion</h2>
    <p class="text-gray-700">
      We craft bespoke festival strategies for short and feature films. From selecting the right festivals to preparing submission materials, we maximize your chances of selection and awards. Our network spans A-list festivals worldwide.
    </p>
  </Card>
  <Card class="p-6">
    <h2 class="text-2xl font-bold mb-3">Creative Services</h2>
    <p class="text-gray-700">
      Professional translation and subtitling in over 30 languages. We also design key visuals, posters, press kits, and social media assets that make your project stand out.
    </p>
  </Card>
  <Card class="p-6">
    <h2 class="text-2xl font-bold mb-3">Cultural Support</h2>
    <p class="text-gray-700">
      We organize art exhibitions, conferences, and live performances. Our sponsorship programs connect independent musicians and visual artists with brands and institutions.
    </p>
  </Card>
  <Card class="p-6">
    <h2 class="text-2xl font-bold mb-3">Consultancy</h2>
    <p class="text-gray-700">
      Logistical and strategic support for speakers, performers, and cultural delegations at international events. We handle travel, accommodation, and scheduling so you can focus on your presentation.
    </p>
  </Card>
</div>
EOF

# 21. festivals/+page.svelte
cat > src/routes/festivals/+page.svelte << 'EOF'
<script lang="ts">
  import { onMount } from 'svelte';
  import Filter from '$lib/components/Filter.svelte';
  import EntityList from '$lib/components/EntityList.svelte';
  import FestivalItem from '$lib/components/FestivalItem.svelte';
  import { getFestivals } from '$lib/api/festivals';
  import type { Festival } from '$lib/types';

  let items = $state<Festival[]>([]);
  let currentPage = $state(1);
  let totalPages = $state(0);
  let loading = $state(false);
  let filters = $state<{ country: string; year: number | null }>({ country: '', year: null });

  let availableCountries = $state<string[]>([]);
  let availableYears = $state<number[]>([]);

  async function loadFestivals() {
    loading = true;
    try {
      const filterParams: any = {};
      if (filters.country) filterParams.country = filters.country;
      if (filters.year) filterParams.year = filters.year;

      const data = await getFestivals(currentPage, 20, filterParams);
      items = data.items;
      totalPages = data.totalPages;

      if (items.length > 0) {
        availableCountries = [...new Set(items.map(i => i.country).filter(Boolean))].sort();
        availableYears = [...new Set(items.map(i => i.year_founded).filter(Boolean))].sort((a,b) => a - b);
      }
    } catch (e) {
      console.error('Failed to load festivals', e);
    } finally {
      loading = false;
    }
  }

  function handleFilter(newFilters: { country: string; year: number | null }) {
    filters = newFilters;
    currentPage = 1;
    loadFestivals();
  }

  function handlePageChange(page: number) {
    currentPage = page;
    loadFestivals();
  }

  onMount(() => {
    loadFestivals();
  });
</script>

<h1 class="text-3xl font-bold my-6">Festivals</h1>

<Filter
  countries={availableCountries}
  years={availableYears}
  onFilter={handleFilter}
/>

{#if loading}
  <p class="text-center">Loading...</p>
{:else}
  <EntityList
    items={items}
    currentPage={currentPage}
    totalPages={totalPages}
    onPageChange={handlePageChange}
  >
    {#snippet children(item: Festival)}
      <FestivalItem festival={item} />
    {/snippet}
  </EntityList>
{/if}
EOF

# 22. festivals/[id]/+page.svelte
cat > src/routes/festivals/[id]/+page.svelte << 'EOF'
<script lang="ts">
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { getFestivalById } from '$lib/api/festivals';
  import type { Festival } from '$lib/types';
  import { Card, Button } from 'flowbite-svelte';

  let festival = $state<Festival | null>(null);
  let loading = $state(true);

  onMount(async () => {
    const id = $page.params.id;
    if (id) {
      try {
        festival = await getFestivalById(id);
      } catch (e) {
        console.error('Failed to load festival', e);
      } finally {
        loading = false;
      }
    }
  });
</script>

{#if loading}
  <p>Loading...</p>
{:else if festival}
  <Card class="p-6 max-w-4xl mx-auto my-8">
    <h1 class="text-3xl font-bold mb-4">{festival.name}</h1>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      {#if festival.logo_url}
        <img src={festival.logo_url} alt={festival.name} class="w-full rounded" />
      {/if}
      <div class="md:col-span-2 space-y-4">
        <p><span class="font-semibold">Country:</span> {festival.country}</p>
        <p><span class="font-semibold">City:</span> {festival.city}</p>
        <p><span class="font-semibold">Founded:</span> {festival.year_founded}</p>
        {#if festival.website}
          <p><span class="font-semibold">Website:</span> <a href={festival.website} target="_blank" class="text-blue-600 hover:underline">{festival.website}</a></p>
        {/if}
      </div>
    </div>
    {#if festival.about}
      <div class="mt-6">
        <h2 class="text-xl font-semibold mb-2">About</h2>
        <p class="whitespace-pre-line">{festival.about}</p>
      </div>
    {/if}
    {#if festival.address}
      <div class="mt-6">
        <h2 class="text-xl font-semibold mb-2">Address</h2>
        <p class="whitespace-pre-line">{festival.address}</p>
      </div>
    {/if}
    {#if festival.awards}
      <div class="mt-6">
        <h2 class="text-xl font-semibold mb-2">Awards</h2>
        <p class="whitespace-pre-line">{festival.awards}</p>
      </div>
    {/if}
    {#if festival.rules}
      <div class="mt-6">
        <h2 class="text-xl font-semibold mb-2">Rules</h2>
        <p class="whitespace-pre-line">{festival.rules}</p>
      </div>
    {/if}
    {#if festival.premiere_requirements}
      <div class="mt-6">
        <h2 class="text-xl font-semibold mb-2">Premiere Requirements</h2>
        <p>{festival.premiere_requirements}</p>
      </div>
    {/if}
    <div class="mt-8">
      <Button href="/festivals">Back to festivals</Button>
    </div>
  </Card>
{:else}
  <p class="text-center text-red-500">Festival not found.</p>
{/if}
EOF

# 23. conferences/+page.svelte
cat > src/routes/conferences/+page.svelte << 'EOF'
<script lang="ts">
  import EntityList from '$lib/components/EntityList.svelte';
  import { getConferences } from '$lib/api/conferences';
  import type { Conference } from '$lib/types';
  import { onMount } from 'svelte';

  let items = $state<Conference[]>([]);
  let currentPage = $state(1);
  let totalPages = $state(0);
  let loading = $state(false);

  onMount(async () => {
    loading = true;
    try {
      const data = await getConferences(currentPage, 20);
      items = data.items;
      totalPages = data.totalPages;
    } catch (e) {
      console.error(e);
    } finally {
      loading = false;
    }
  });

  function handlePageChange(page: number) {
    currentPage = page;
    // TODO: reload
  }
</script>

<h1 class="text-3xl font-bold my-6">Conferences</h1>

{#if loading}
  <p>Loading...</p>
{:else}
  <EntityList
    {items}
    {currentPage}
    {totalPages}
    onPageChange={handlePageChange}
  >
    {#snippet children(item: Conference)}
      <div class="bg-white p-4 rounded shadow">
        <h3 class="font-bold">{item.name || 'Conference name'}</h3>
        <p>Country: {item.country || '—'}</p>
        <p>Year: {item.year || '—'}</p>
      </div>
    {/snippet}
  </EntityList>
{/if}
EOF

# 24. partners/+page.svelte
cat > src/routes/partners/+page.svelte << 'EOF'
<script lang="ts">
  import { onMount } from 'svelte';
  import EntityList from '$lib/components/EntityList.svelte';
  import { getPartners } from '$lib/api/partners';
  import type { Partner } from '$lib/types';
  import { Card, Button } from 'flowbite-svelte';

  let items = $state<Partner[]>([]);
  let currentPage = $state(1);
  let totalPages = $state(0);
  let loading = $state(false);

  async function loadPartners() {
    loading = true;
    try {
      const data = await getPartners(currentPage, 20);
      items = data.items;
      totalPages = data.totalPages;
    } catch (e) {
      console.error('Failed to load partners', e);
    } finally {
      loading = false;
    }
  }

  function handlePageChange(page: number) {
    currentPage = page;
    loadPartners();
  }

  onMount(() => {
    loadPartners();
  });
</script>

<h1 class="text-3xl font-bold my-6">Partners</h1>

{#if loading}
  <p class="text-center">Loading...</p>
{:else}
  <EntityList
    items={items}
    {currentPage}
    {totalPages}
    onPageChange={handlePageChange}
  >
    {#snippet children(item: Partner)}
      <Card class="h-full flex flex-col">
        {#if item.image}
          <img src={item.image} alt={item.name} class="w-full h-40 object-cover rounded-t-lg" />
        {/if}
        <h5 class="text-xl font-bold mt-2">{item.name}</h5>
        <p class="text-gray-600">{item.type} • {item.country}</p>
        {#if item.summary}
          <p class="mt-2 text-sm line-clamp-3">{item.summary}</p>
        {/if}
        <div class="mt-4">
          <Button href={item.link || '#'} size="sm" target="_blank">Learn more</Button>
        </div>
      </Card>
    {/snippet}
  </EntityList>
{/if}
EOF

# 25. contacts/+page.svelte
cat > src/routes/contacts/+page.svelte << 'EOF'
<script lang="ts">
  import { Card } from 'flowbite-svelte';
</script>

<h1 class="text-3xl font-bold my-6">Contacts</h1>

<Card class="p-6 max-w-2xl mx-auto">
  <h2 class="text-2xl font-semibold mb-4">Provincial s.r.o.</h2>
  <div class="space-y-3 text-gray-700">
    <p><span class="font-medium">ID:</span> 19287321</p>
    <p><span class="font-medium">Address:</span> Jaltska 1107/14, 360 01 Karlovy Vary, Czech Republic</p>
    <p><span class="font-medium">Email:</span> <a href="mailto:info@aparteu.com" class="text-blue-600 hover:underline">info@aparteu.com</a></p>
    <p><span class="font-medium">Phone:</span> <a href="tel:+420607191489" class="text-blue-600 hover:underline">+420 607 191 489</a></p>
  </div>
</Card>
EOF

# 26. logo.svg (заглушка)
cat > static/logo.svg << 'EOF'
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect width="32" height="32" rx="8" fill="#3B82F6"/>
  <text x="6" y="22" font-family="Arial" font-size="18" fill="white" font-weight="bold">P</text>
</svg>
EOF

# 27. Убедимся, что layout.css существует (он уже есть)
echo "✅ Генерация файлов завершена!"
echo "📁 Все необходимые файлы созданы."
echo "🚀 Запустите: pnpm run dev"
echo "🌐 Откройте http://localhost:5173"