<template>
  <div>
    <section id="map-container" class="map-container" @mousemove.prevent="doDrag">
      <div class="center">
        <input-field v-model="mainIdea" @start-drag="startDrag"></input-field>
      </div>
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

          // To prevent adding new input box if user clicks on input circle.
          if (this.x == 0 && this.y == 0) {return;}
          console.log(this.x, this.y)
          var node = document.createElement('DIV');
          var input_node = document.createElement("INPUT");
          input_node.setAttribute("type", "text");
          input_node.value = "New Idea";
          input_node.style.padding = '3% 5%';
          input_node.style.border = '1px solid';
          input_node.style.textAlign = 'center';
          input_node.style.borderRadius = "11%";
          input_node.style.fontWeight = "700";
          input_node.style.fontSize = "80%";
          node.appendChild(input_node);
          node.style.position = 'absolute';
          node.style.left = this.x + "px";
          node.style.top = this.y + "px";
          document.getElementById('map-container').appendChild(node);
          var parent = document.getElementsByClassName('center')[0];
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
          this.x = event.clientX + 1;
          this.y = event.clientY + 1;

          var c = document.getElementById(this.parentX + "")
          var ctx = c.getContext("2d");
          ctx.clearRect(0, 0, c.width, c.height)
          ctx.beginPath();

          ctx.lineWidth = "5";
          ctx.strokeStyle = "red";
          ctx.moveTo(this.parentX, this.parentY);
          ctx.lineTo(this.x, this.y);
          ctx.stroke();
        }
      }
    },
    mounted() {
      window.addEventListener('mouseup', this.stopDrag);
    },
    watch: {
      connections: function(cons) {
        document.querySelectorAll("canvas").forEach((canvas) => {
          if(canvas.id != "map-canvas") {
            canvas.parentNode.removeChild(canvas)
          }
        })
        var c = document.getElementById("map-canvas")
        var ctx = c.getContext("2d");

        ctx.lineWidth = 5;
        ctx.strokeStyle = "red";
        
        cons.forEach((con) => {
          ctx.beginPath();
          ctx.moveTo(con.parentX, con.parentY);
          ctx.lineTo(con.childX, con.childY);
          ctx.stroke();
          ctx.closePath();
        })
      }
    }
  }
</script>

<style scoped lang="scss">
  .new_idea_button {
    background-color: #17a2b8;
    padding: 2vh;
    font-size: 3vh;
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
</style>
