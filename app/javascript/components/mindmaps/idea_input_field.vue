<template>
  <div>
    <span @mousedown="startDrag" class="start_dot"></span>
    <input type="text" v-model="value" class="central_idea"/>
  </div>
</template>

<script>
  export default {
    props: ['value'],
    methods: {
      startDrag(event) {
        this.$emit('start-drag', event);
      }
    },
    watch: {
      value() {
        this.$emit("input", this.value)
      }
    }
  }
  
</script>

<style scoped lang="scss">
  .central_idea {
    text-align: center;
    padding: 5% 7%;
    border: 1px solid;
    border-radius: 11%;
    font-weight: 900;
    font-size: 100%;
  }
  .start_dot {
    cursor: grab;
    height: 10px;
    width: 10px;
    background-color: #f00;
    border-radius: 50%;
    display: inline-block;
    position: absolute;
    left: 130px;
    top: 40px;
  }
  .start_dot:hover {
    border: 5px solid cornflowerblue;
  }
</style>