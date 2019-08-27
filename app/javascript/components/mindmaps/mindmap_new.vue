<template>
  <div>
    <section v-if="!loading" id="map-container" class="map-container" @mousemove.prevent="doDrag">
      <div class="center" :style="C_centeralNodePosition">
        <span @mousedown="startDrag" class="start_dot"></span>
        <input type="text" ref="central_idea" @input="updateCentralIdea" v-model="centralIdea" class="central_idea"/>
      </div>
      <input-field 
        @mousedown-event="startDragNode($event, node)" 
        v-for="node in currentMindMap.nodes" 
        :key="`${node.position_x}.${node.position_y}`" 
        v-model="node.title" 
        @start-drag="startDrag($event, node)" 
        :style="getNodeStyle(node)" 
        class="pos_abs input_field"></input-field>
      <canvas id="map-canvas" :width="windowWidth" :height="windowHeight"></canvas>
    </section>
    <div class="buttons_area">
      <span>
        <button @click.stop="$refs.newMapModal.open" class="options_button">New</button>
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
      <p class="text-muted fs_18">You may want to open in new Tab!</p>
      <div class="center_flex mt_2">
        <a 
          href="javascript:;" 
          class="btn_2 bg-danger text-white mr_1"
          @click.stop="openNewMap" 
        >
          <i class="material-icons mr-1">done</i>
          Continue Here
        </a>
        <a 
          href="javascript:;" 
          class="btn_2 bg-warning text-white mr_1"
          @click.stop="openNewMapNewWindow" 
        >
          <i class="material-icons mr-1">open_in_new</i>
          Open new Tab!
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
    <sweet-modal ref="openMapModal" class="of_v">
      <div class="sweet_model_icon_div">
        <div class="radius_circle bg-success center_flex mlr_a">
          <i class="material-icons text-white">folder_open</i>
        </div>
      </div>
      <p class="text-muted fs_18">Enter the map key you want to open here!</p>
      <div class="form-horizontal">   
        <div class="row form-group mt-2">
          <label class="control-label col-4" for="mindmap_name">Mindmap key:</label>
          <input type="text" placeholder="Enter map id" v-model="openMindMapKey" class="form-control col-6 ">
        </div>
      </div>
      <div class="center_flex mt_2">
        <a 
          href="javascript:;" 
          class="btn_2 bg-success text-white mr_1"
          @click.stop.prevent="openPreviousMap" 
        >
          <i class="material-icons mr-1">done</i>
          Open
        </a>
        <a 
          href="javascript:;" 
          class="btn_2 bg-primary text-white mr_1"
          @click.stop.prevent="$refs.openMapModal.close" 
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
  import _ from 'lodash';

  export default {
    components: {InputField, SweetModal},
    data() {
      return {
        selectedNode: null,
        nodeParent: null,
        centralIdea: '',
        currentMindMap: {},
        loading: true,
        dragging: false,
        draggingNode: false,
        currentPositionX: 0,
        currentPositionY: 0,
        nodeOffsetX: 0,
        nodeOffsetY: 0,
        parent_x: 0,
        parent_y: 0,
        windowWidth: window.innerWidth,
        windowHeight: window.innerHeight,
        stopWatch: false,
        openMindMapKey: ''
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
      getMindmap(id) {
        http.get(`/mindmaps/${id}.json`).then((res) => {
          this.stopWatch = true;
          this.currentMindMap = res.data.mindmap;
          setTimeout(this.drawLines, 100);
          this.closeOpenMapModal();
          this.updateQuery();
          this.loading = false;
        }).catch((error) => {
          alert(`Mind map with id ${id} not found`);
          console.log(error);
        })
      },
      openPreviousMap() {
        this.getMindmap(this.openMindMapKey);
      },
      closeOpenMapModal() {
        this.openMindMapKey = '';
        this.$refs.openMapModal.close();
      },
      getNewMindmap() {
        http.get('/mindmaps/new.json').then((res) => {
          this.currentMindMap = res.data.mindmap;
          let query = {};
          delete query['key'];
          this.$router.push({query: query});
          this.loading = false;
        }).catch((error) => {
          console.log(error);
          this.loading = false;
        })
      },
      startDrag(event, p_node=null) {
        console.log("start Drag");
        if (p_node) {
          this.nodeParent = p_node;
        }
        this.dragging = true;
        this.parent_x = event.clientX;
        this.parent_y = event.clientY;
        let canvas_id = this.parent_x + "";
        if (!document.getElementById(canvas_id)) {
          var c = document.createElement('CANVAS');
          c.id = this.parent_x + "";
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
          this.draggingNode = false;
          console.log("stopped new node");

          // To prevent adding new input box if user clicks on red circle.
          this.removeLines();
          if (this.currentPositionX == 0 && this.currentPositionY == 0) {return;}

          if ((this.windowWidth - this.currentPositionX) < 100) {
            this.currentPositionX -= 150;
          }
          if ((this.windowHeight - this.currentPositionY) < 50) {
            this.currentPositionY -= 50;
          }
          let node = {
            title: "New Idea",
            position_x: this.currentPositionX,
            position_y: this.currentPositionY,
            parent_node: this.nodeParent ? this.nodeParent.id : 0
          }
          this.currentMindMap.nodes.push(node);
          this.currentPositionX = this.currentPositionY = 0;
          this.nodeParent = null;
        } 
        if (this.draggingNode) {
          this.dragging = false;
          this.draggingNode = false;
          this.saveCurrentMap()
          this.selectedNode = null;
          console.log("stoped old node");
          this.removeLines();
        }
      },
      doDrag(event) {
        if (this.dragging) {
          console.log("dragging new node");
          this.currentPositionX = event.clientX ;
          this.currentPositionY = event.clientY ;

          var c = document.getElementById(this.parent_x + "")
          var ctx = c.getContext("2d");
          ctx.clearRect(0, 0, c.width, c.height)
          ctx.beginPath();

          ctx.lineWidth = "2";
          ctx.strokeStyle = "red";
          ctx.moveTo(this.parent_x, this.parent_y);
          ctx.lineTo(this.currentPositionX, this.currentPositionY);
          ctx.stroke();
        } else if (this.draggingNode) {
          console.log("dragging old node");
          let node = this.currentMindMap.nodes.findIndex((nod) => nod.id == this.selectedNode.id);
          this.stopWatch = true;
          this.currentMindMap.nodes[node].position_x = event.clientX - this.nodeOffsetX;
          this.stopWatch = true;
          this.currentMindMap.nodes[node].position_y = event.clientY - this.nodeOffsetY;
        }
      },
      getNodeStyle(node) {
        return {left: node.position_x +'px', top: node.position_y +'px'}
      },
      openNewMap() {
        this.getNewMindmap();
        this.$refs.newMapModal.close()
      },
      openNewMapNewWindow() {
        window.open(window.location.origin+'/mindmaps/new')
      },
      saveCurrentMap(restore=false) {
        if (this.currentMindMap.nodes.length == 0 && restore == false) { return; }
        if (this.currentMindMap.id) {
          http.put(`/mindmaps/${this.currentMindMap.id}.json`, {mindmap: this.currentMindMap}).then((res) => {
            this.stopWatch = true;
            this.currentMindMap = res.data.mindmap;
            this.updateQuery();
          }).catch((error) => {
            console.log(error)
          })
        } else {
          http.post(`/mindmaps.json`, {mindmap: this.currentMindMap}).then((res) => {
            this.stopWatch = true;
            this.currentMindMap = res.data.mindmap;
            this.updateQuery();
          }).catch((error) => {
            console.log(error)
          })
        }
      },
      resetMindmapap() {
        this.stopWatch = true;
        this.currentMindMap.name = "Central Idea";
        this.stopWatch = true;
        this.currentMindMap.nodes = [];

        this.saveCurrentMap(true);
        this.$refs.resetMapModal.close();
      },
      updateQuery() {
        let query = {};
        query['key'] = this.currentMindMap.id;
        this.$router.push({query: query});
      },
      drawLines(retry_count=0) {
        return;
        if (document.getElementById("map-canvas") != null) {
          this.removeLines();
          var c = document.getElementById("map-canvas")
          if (!c) { return; }
          var ctx = c.getContext("2d");
          ctx.clearRect(0, 0, c.width, c.height)

          ctx.lineWidth = "2";
          ctx.strokeStyle = "red";
          
          this.currentMindMap.connections.forEach((con) => {
            ctx.beginPath();
            ctx.moveTo(con.child_x, con.child_y);
            ctx.lineTo(con.parent_x, con.parent_y);
            ctx.stroke();
            ctx.closePath();
          })
        } else if (retry_count < 5) {
          setTimeout(this.drawLines(retry_count++), 100); 
        }
      },
      updateCentralIdea: _.debounce(
        function(input) {
          this.currentMindMap.name = this.$refs.central_idea.value;
        },
        500
      ),
      startDragNode(event, node) {
        console.log("started node drag");
        this.selectedNode = node;
        this.nodeOffsetX = event.clientX - node.position_x;
        this.nodeOffsetY = event.clientY - node.position_y;
        this.draggingNode = true;
        this.currentPositionX = this.currentPositionY = 0;
      },
      removeLines() {
        document.querySelectorAll("CANVAS").forEach((canvas) => {
          if(canvas.id != "map-canvas") {
            canvas.parentNode.removeChild(canvas)
          }
        })
      }
    },
    mounted() {
      if (this.$route.query.key) {
        this.getMindmap(this.$route.query.key)
      } else {
        this.getNewMindmap();
      }
      window.addEventListener('mouseup', this.stopDrag);
    },
    watch: {
      currentMindMap: {
        handler: function(new_map) {
          this.centralIdea = this.currentMindMap.name;
          this.removeLines();
          // var c = document.getElementById("map-canvas")
          // if (!c) { return; }
          // var ctx = c.getContext("2d");
          // ctx.clearRect(0, 0, c.width, c.height)

          // ctx.lineWidth = "2";
          // ctx.strokeStyle = "red";
          
          // new_map.connections.forEach((con) => {
          //   ctx.beginPath();
          //   ctx.moveTo(con.child_x, con.child_y);
          //   ctx.lineTo(con.parent_x, con.parent_y);
          //   ctx.stroke();
          //   ctx.closePath();
          // })
          if (this.stopWatch) { 
            this.stopWatch = false;
            return; 
          }
          this.saveCurrentMap();
        },
        deep: true
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
  .input_field {
    cursor: pointer;
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
