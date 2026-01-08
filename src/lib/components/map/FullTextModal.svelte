<script>
  export let open = false;
  export let text = "";
  const close = () => dispatch("close");
</script>

{#if open}
  <div class="modal-backdrop" onclick={close}></div>
  <div class="modal">
    <button class="close-btn" onclick={close}>×</button>

    <div class="modal-content">
      <h3>Full Report</h3>
      <p>{text}</p>
    </div>
  </div>
{/if}


<style>
    
</style>