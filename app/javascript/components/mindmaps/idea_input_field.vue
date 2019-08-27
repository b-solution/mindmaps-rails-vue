<template>
  <div @mousedown="startDragIdea" class="">
    <span @mousedown="startDrag" class="start_dot"></span>
    <input type="text" ref="new_idea" @input="updateIdea" v-model="tempLocalValue" class="new_idea"/>
  </div>
</template>

<script>
  import _ from 'lodash';

  export default {
    props: ['value'],
    data() {
      return {
        localValue: this.value,
        tempLocalValue: this.value
      }
    },
    methods: {
      startDrag(event) {
        this.$emit('start-drag', event);
      },
      updateIdea: _.debounce(
        function(input) {
          this.localValue = this.$refs.new_idea.value;
          this.tempLocalValue = this.$refs.new_idea.value;
        },
        500
      ),
      startDragIdea(event) {
        this.$emit('mousedown-event', event);
      }
    },
    watch: {
      localValue() {
        this.$emit("input", this.localValue)
      }
    }
  }
  
</script>

<style scoped lang="scss">
  .new_idea {
    text-align: center;
    padding: 5% 5%;
    border: 1px solid;
    border-radius: 11%;
    font-weight: 700;
    font-size: 80%;
  }
  .start_dot {
    cursor: grab;
    height: 10px;
    width: 10px;
    background-color: #f00;
    border-radius: 50%;
    display: inline-block;
    position: absolute;
    left: 80px;
    top: 15px;
  }
  .start_dot:hover {
    border: 5px solid cornflowerblue;
  }
</style>