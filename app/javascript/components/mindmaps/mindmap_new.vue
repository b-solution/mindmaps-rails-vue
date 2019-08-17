<template>
  <div>
    <section id="map-container" class="map-container" @mousemove.prevent="doDrag">
      <div class="center">
        <span @mousedown="startDrag" class="start_dot"></span>
        <input type="text" v-model="mainIdea" class="central_idea"/>       
      </div>
      <canvas id="map-canvas" width="1200" height="1200"></canvas>
    </section>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        mainIdea: "Central Idea",
        nodes: [],
        connections: [],
        dragging: false,
        x: 0,
        y: 0,
        parentX: 0,
        parentY: 0
      }
    },
    methods: {
      startDrag(event) {
        this.dragging = true
        this.parentX = event.clientX
        this.parentY = event.clientY
        var c=document.createElement('CANVAS')
        c.id=this.parentX + "";
        document.getElementById('map-container').appendChild(c)
        c.style.position="absolute"
        c.style.top=0
        c.style.left=0
        c.width = 1200//Math.abs(this.parentX, this.x)
        c.height = 1200//Math.abs(this.parentY, this.y)
        this.x = this.y = 0
      },
      stopDrag(event) {
        if (this.dragging) {
          this.dragging = false
          var node=document.createElement('DIV')
          var input_node=document.createElement("INPUT");
          input_node.setAttribute("type", "text");
          input_node.value = "New Idea";
          node.appendChild(input_node)
          node.style.position = 'absolute'
          node.style.left= this.x + "px"
          node.style.top=this.y + "px"
          document.getElementById('map-container').appendChild(node)
          var parent = document.getElementsByClassName('center')[0]
          this.connections.push({parentX: this.parentX, parentY: this.parentY, childX: this.x, childY: this.y})
          this.x = this.y = 0
        }
      },
      doDrag(event) {
        if (this.dragging) {
          this.x = event.clientX;
          this.y = event.clientY;

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
  .central_idea {
    text-align: center;
    padding: 5% 7%;
    border: 1px solid;
    border-radius: 11%;
    font-weight: 900;
    font-size: 100%;
  }
  .new_idea {
    text-align: center;
    padding: 3% 5%;
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
    left: 130px;
    top: 40px;
  }
  .start_dot:hover {
    border: 5px solid cornflowerblue;
  }
  .center {
    position: absolute;
    top: 300px;
    left: 650px;
    align-items: center;
    z-index: 100;
  }
</style>