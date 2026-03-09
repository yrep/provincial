<script lang="ts">
  let { children }: { children: any } = $props();
</script>

<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  {@render children()}
</div>