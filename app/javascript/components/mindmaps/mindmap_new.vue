<template>
  <div>
    <section id="map-container" class="map-container" @mousemove.prevent="doDrag">
      <div class="center">
        <span @mousedown="startDrag" class="start_dot"></span>
        <input type="text" v-model="mainIdea" class="central_idea"/>
      </div>
      <input-field v-for="node in nodes" v-model="node.value" @start-drag="startDrag" :style="getNodeStyle(node)" class="pos_abs"></input-field>
      <canvas id="map-canvas" :width="windowWidth" height="1500"></canvas>
    </section>
    <div class="buttons_area">
      <span>
        <button class="new_idea_button">New Idea</button>
      </span>
    </div>
  </div>
</template>

<script>
  import InputField from './idea_input_field'

  export default {
    components: {InputField},
    data() {
      return {
        mainIdea: "Central Idea",
        nodes: [],
        connections: [],
        dragging: false,
        x: 0,
        y: 0,
        parentX: 0,
        parentY: 0,
        windowWidth: window.innerWidth
      }
    },
    methods: {
      startDrag(event) {
        this.dragging = true;
        this.parentX = event.clientX;
        this.parentY = event.clientY;
        let canvas_id = this.parentX + "";
        if (!document.getElementById(canvas_id)) {
          var c = document.createElement('CANVAS');
          c.id = this.parentX + "";
          document.getElementById('map-container').appendChild(c);
          c.style.position="absolute";
          c.style.top = 0;
          c.style.left = 0;
          c.width = this.windowWidth;
          c.height = 1500;
        }
        this.x = this.y = 0;
      },
      stopDrag(event) {
        if (this.dragging) {
          this.dragging = false;

          // To prevent adding new input box if user clicks on red circle.
          if (this.x == 0 && this.y == 0) {return;}
          let node = {
            value: "New Idea",
            left: this.x,
            top: this.y
          }
          this.nodes.push(node);
          this.connections.push({
            parentX: this.parentX, 
            parentY: this.parentY, 
            childX: this.x, 
            childY: this.y
          });
          this.x = this.y = 0;
        }
      },
      doDrag(event) {
        if (this.dragging) {
          this.x = event.clientX ;
          this.y = event.clientY ;

          var c = document.getElementById(this.parentX + "")
          var ctx = c.getContext("2d");
          ctx.clearRect(0, 0, c.width, c.height)
          ctx.beginPath();

          ctx.lineWidth = "2";
          ctx.strokeStyle = "red";
          ctx.moveTo(this.parentX, this.parentY);
          ctx.lineTo(this.x, this.y);
          ctx.stroke();
        }
      },
      getNodeStyle(node) {
        return {left: node.left +'px', top: node.top +'px'}
      }
    },
    mounted() {
      window.addEventListener('mouseup', this.stopDrag);
    },
    watch: {
      connections: function(cons) {
        document.querySelectorAll("CANVAS").forEach((canvas) => {
          if(canvas.id != "map-canvas") {
            canvas.parentNode.removeChild(canvas)
          }
        })
        var c = document.getElementById("map-canvas")
        var ctx = c.getContext("2d");
        ctx.clearRect(0, 0, c.width, c.height)

        ctx.lineWidth = "2";
        ctx.strokeStyle = "red";
        
        cons.forEach((con) => {
          ctx.beginPath();
          ctx.moveTo(con.childX, con.childY);
          ctx.lineTo(con.parentX, con.parentY);
          ctx.stroke();
          ctx.closePath();
        })
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
  .pos_abs {
    position: absolute !important;
  }
  .new_idea_button {
    background-color: #17a2b8;
    padding: 1vh;
    font-size: 2vh;
  }
  .buttons_area {
    position: absolute;
    left: 93%;
    top: 15px;
  }
  .center {
    position: absolute;
    top: 300px;
    left: 650px;
    align-items: center;
    z-index: 100;
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
