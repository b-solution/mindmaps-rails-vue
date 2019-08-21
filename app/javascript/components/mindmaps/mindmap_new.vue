<template>
  <div>
    <section v-if="!loading" id="map-container" class="map-container" @mousemove.prevent="doDrag">
      <div class="center" :style="C_centeralNodePosition">
        <span @mousedown="startDrag" class="start_dot"></span>
        <input type="text" v-model="currentMindMap.name" class="central_idea"/>
      </div>
      <input-field v-for="node in currentMindMap.nodes" :key="`${node.left}.${node.top}`" v-model="node.title" @start-drag="startDrag" :style="getNodeStyle(node)" class="pos_abs"></input-field>
      <canvas id="map-canvas" :width="windowWidth" :height="windowHeight"></canvas>
    </section>
    <div class="buttons_area">
      <span>
        <button @click.stop="$refs.newMapModal.open" class="options_button">New</button>
        <button @click.stop="$refs.saveMapModal.open" class="options_button">Save</button>
        <button @click.stop="$refs.openMapModal.open" class="options_button">Open</button>
        <button @click.stop="$refs.resetMapModal.open" class="options_button">Reset</button>
      </span>
    </div>
    <sweet-modal ref="newMapModal" class="of_v">
      <div class="sweet_model_icon_div">
        <div class="radius_circle bg-warning center_flex mlr_a">
          <i class="material-icons text-white">error_outline</i>
        </div>
      </div>
      <h3 class="f_smooth_auto">Are you Sure?</h3>
      <p class="text-muted fs_18">Your current changes will be discarded, you won't be able to revert this. You may want to open in new Tab!</p>
      <div class="center_flex mt_2">
        <a 
          href="javascript:;" 
          class="btn_2 bg-danger text-white mr_1"
          @click.stop="openNewMap" 
        >
          <i class="material-icons mr-1">done</i>
          Continue
        </a>
        <a 
          href="javascript:;" 
          class="btn_2 bg-warning text-white mr_1"
          @click.stop="openNewMapNewWindow" 
        >
          <i class="material-icons mr-1">open_in_new</i>
          Open in new Tab!
        </a>
        <a 
          href="javascript:;" 
          class="btn_2 bg-primary text-white mr_1"
          @click.stop="$refs.newMapModal.close" 
        >
          <i class="material-icons mr-1">cancel</i>
          Cancel
        </a>
      </div>
    </sweet-modal>
    <sweet-modal ref="saveMapModal" class="of_v">
      <div class="sweet_model_icon_div">
        <div class="radius_circle bg-success center_flex mlr_a">
          <i class="material-icons text-white">save</i>
        </div>
      </div>
      <div class="col form-inline center_flex">
        <label for="mindmap_name">Mindmap Name:</label>
        <input type="text" placeholder="Enter a unique name" v-model="currentMindMap.name" name="mindmap[name]" class="ml-3 form-control">
      </div>
      <div class="center_flex mt_2">
        <a 
          href="javascript:;" 
          class="btn_2 bg-success text-white mr_1"
          @click.stop="saveCurrentMap" 
        >
          <i class="material-icons mr-1">done</i>
          Save
        </a>
        <a 
          href="javascript:;" 
          class="btn_2 bg-primary text-white mr_1"
          @click.stop="$refs.saveMapModal.close" 
        >
          <i class="material-icons mr-1">cancel</i>
          Cancel
        </a>
      </div>
    </sweet-modal>
    <sweet-modal ref="openMapModal" class="of_v">
      <div class="sweet_model_icon_div">
        <div class="radius_circle bg-success center_flex mlr_a">
          <i class="material-icons text-white">folder_open</i>
        </div>
      </div>
      <p class="text-muted fs_18">Just a heads-up! Your current map will be discarded. You may want save this before opening a new map.</p>
      <p class="text-muted fs_18">Enter the map details you want to open here!</p>
      <form class="form-horizontal">   
        <div class="row form-group">
          <label class="control-label col-4" for="mindmap_name">Mindmap Name:</label>
          <input type="text" placeholder="Enter map name" v-model="openMapmind.name" name="mindmap[name]" class="form-control col-6">
        </div>
        <div class="row form-group mt-2">
          <label class="control-label col-4" for="mindmap_name">Mindmap id:</label>
          <input type="text" placeholder="Enter map id" v-model="openMapmind.id" name="mindmap[name]" class="form-control col-6 ">
        </div>
      </form>
      <div class="center_flex mt_2">
        <a 
          href="javascript:;" 
          class="btn_2 bg-success text-white mr_1"
          @click.stop="saveCurrentMap" 
        >
          <i class="material-icons mr-1">done</i>
          Open
        </a>
        <a 
          href="javascript:;" 
          class="btn_2 bg-primary text-white mr_1"
          @click.stop="$refs.openMapModal.close" 
        >
          <i class="material-icons mr-1">cancel</i>
          Cancel
        </a>
      </div>
    </sweet-modal>
    <sweet-modal ref="resetMapModal" class="of_v">
      <div class="sweet_model_icon_div">
        <div class="radius_circle bg-warning center_flex mlr_a">
          <i class="material-icons text-white">restore</i>
        </div>
      </div>
      <h3 class="f_smooth_auto">Are you Sure you want to reset this Map?</h3>
      <p class="text-muted fs_18">Your current changes will be discarded, you won't be able to revert this!</p>
      <div class="center_flex mt_2">
        <a 
          href="javascript:;" 
          class="btn_2 bg-danger text-white mr_1"
          @click.stop="resetMindmapap" 
        >
          <i class="material-icons mr-1">done</i>
          Continue
        </a>
        <a 
          href="javascript:;" 
          class="btn_2 bg-primary text-white mr_1"
          @click.stop="$refs.resetMapModal.close" 
        >
          <i class="material-icons mr-1">cancel</i>
          Cancel
        </a>
      </div>
    </sweet-modal>
  </div>
</template>

<script>
  import InputField from './idea_input_field'
  import http from '../../common/http'
  import {SweetModal }from 'sweet-modal-vue';

  export default {
    components: {InputField, SweetModal},
    data() {
      return {
        currentMindMap: {},
        loading: true,
        dragging: false,
        currentPositionX: 0,
        currentPositionY: 0,
        parentX: 0,
        parentY: 0,
        windowWidth: window.innerWidth,
        windowHeight: window.innerHeight,
        openMapmind: {
          name: '',
          id: ''
        }
      }
    },
    computed: {
      C_centeralNodePosition() {
        return {
          left: (Math.floor(this.windowWidth/2) - 150) +'px', 
          top: (Math.floor(this.windowHeight/2) - 50) +'px'
        }
      }
    },
    methods: {
      getMinmap(id) {
        http.get(`/mindmaps/${id}.json`).then((res) => {
          this.currentMindMap = res.data.mindmap;
          this.loading = false;
        }).catch((error) => {
          console.log(error);
        })
      },
      getNewMindmap() {
        http.get('/mindmaps/new.json').then((res) => {
          this.currentMindMap = res.data.mindmap;
          this.loading = false;
        }).catch((error) => {
          console.log(error);
          this.loading = false;
        })
      },
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
          c.height = this.windowHeight;
        }
        this.currentPositionX = this.currentPositionY = 0;
      },
      stopDrag(event) {
        if (this.dragging) {
          this.dragging = false;

          // To prevent adding new input box if user clicks on red circle.
          if (this.currentPositionX == 0 && this.currentPositionY == 0) {return;}
          let node = {
            title: "New Idea",
            left: this.currentPositionX,
            top: this.currentPositionY
          }
          this.currentMindMap.nodes.push(node);
          this.currentMindMap.connections.push({
            parentX: this.parentX, 
            parentY: this.parentY, 
            childX: this.currentPositionX, 
            childY: this.currentPositionY
          });
          this.currentPositionX = this.currentPositionY = 0;
        }
      },
      doDrag(event) {
        if (this.dragging) {
          this.currentPositionX = event.clientX ;
          this.currentPositionY = event.clientY ;

          var c = document.getElementById(this.parentX + "")
          var ctx = c.getContext("2d");
          ctx.clearRect(0, 0, c.width, c.height)
          ctx.beginPath();

          ctx.lineWidth = "2";
          ctx.strokeStyle = "red";
          ctx.moveTo(this.parentX, this.parentY);
          ctx.lineTo(this.currentPositionX, this.currentPositionY);
          ctx.stroke();
        }
      },
      getNodeStyle(node) {
        return {left: node.left +'px', top: node.top +'px'}
      },
      openNewMap() {
        this.getNewMindmap();
        this.$refs.newMapModal.close()
      },
      openNewMapNewWindow() {
        window.open(window.location.origin+'/mindmaps/new')
      },
      saveCurrentMap() {
        this.$refs.saveMapModal.close();
      },
      resetMindmapap() {
        // Add logic to reset same map on frontend and backend both
        // Temporaryly adding new map instead of resetting 
        this.getNewMindmap();
        this.$refs.resetMapModal.close();
      }
    },
    mounted() {
      if (this.$route.query.key) {
        this.getMinmap(this.$route.query.key)
      } else {
        this.getNewMindmap();
      }
      window.addEventListener('mouseup', this.stopDrag);
    },
    watch: {
      "currentMindMap.connections": function(cons) {
        document.querySelectorAll("CANVAS").forEach((canvas) => {
          if(canvas.id != "map-canvas") {
            canvas.parentNode.removeChild(canvas)
          }
        })
        var c = document.getElementById("map-canvas")
        if (!c) { return; }
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
  .options_button {
    cursor: pointer;
    background-color: #17a2b8;
    padding: 1vh;
    font-size: 20px;
  }
  .buttons_area {
    position: absolute;
    left: 83%;
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
    left: 120px;
    top: 30px;
  }
  .start_dot:hover {
    border: 5px solid cornflowerblue;
  }
</style>
