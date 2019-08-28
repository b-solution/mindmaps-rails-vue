<template>
  <div>
    <section v-if="!loading" id="map-container" class="map-container" @mousemove.prevent="doDrag">
      <div class="center" :style="C_centeralNodePosition">
        <span @mousedown="startDrag" class="start_dot"></span>
        <input type="text" ref="central_idea" @input="updateCentralIdea" v-model="centralIdea" class="central_idea"/>
      </div>
      <input-field 
        v-for="node in currentMindMap.nodes" 
        v-model="node.title" 
        :key="`${node.id}`" 
        :style="getNodeStyle(node)" 
        :is-selected="C_selectedNodeId === node.id"
        @start-drag="startDrag($event, node)" 
        @mousedown-event="startDragNode($event, node)" 
        @node-updated="nodeUpdated(node)"
        class="pos_abs input_field">
        </input-field>
      <canvas id="map-canvas" :width="windowWidth" :height="windowHeight"></canvas>
    </section>
    <div class="buttons_area">
      <span>
        <button @click.stop="deleteSelectedNode" :disabled="!selectedNode" class="options_button">Delete</button>
      </span>
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
        openMindMapKey: '',
        nodeUpdatedFlag: false
      }
    },
    computed: {
      C_centeralNodePosition() {
        return {
          left: (Math.floor(this.windowWidth/2) - 150) +'px', 
          top: (Math.floor(this.windowHeight/2) - 50) +'px'
        }
      },
      C_selectedNodeId() {
        return this.selectedNode ? this.selectedNode.id : 0;
      }
    },
    methods: {
      // =============== GETTING MAP =====================
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
      // =============== GETTING MAP =====================

      // =============== MODALS OPEN/CLOSE/OPERATIONS =====================
      closeOpenMapModal() {
        this.openMindMapKey = '';
        this.$refs.openMapModal.close();
      },
      openPreviousMap() {
        this.getMindmap(this.openMindMapKey);
      },
      openNewMapNewWindow() {
        window.open(window.location.origin+'/mindmaps/new')
      },
      openNewMap() {
        this.getNewMindmap();
        this.$refs.newMapModal.close()
      },
      // =============== MODALS OPEN/CLOSE/OPERATIONS =====================

      // =============== DRAGGING OPERATIONS =====================
      startDrag(event, p_node=null) {
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
      startDragNode(event, node) {
        this.selectedNode = node;
        this.nodeOffsetX = event.clientX - node.position_x;
        this.nodeOffsetY = event.clientY - node.position_y;
        this.draggingNode = true;
        this.currentPositionX = this.currentPositionY = 0;
      },
      doDrag(event) {
        if (this.dragging) {
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
          this.nodeUpdatedFlag = true;
          let node = this.currentMindMap.nodes.findIndex((nod) => nod.id == this.selectedNode.id);
          this.stopWatch = true;
          this.currentMindMap.nodes[node].position_x = event.clientX - this.nodeOffsetX;
          this.stopWatch = true;
          this.currentMindMap.nodes[node].position_y = event.clientY - this.nodeOffsetY;
        }
      },
      stopDrag(event) {
        if (this.dragging) {
          this.dragging = false;
          this.draggingNode = false;

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
          this.selectedNode = null;
          this.createNode(node);
          // this.currentMindMap.nodes.push(node);
          this.currentPositionX = this.currentPositionY = 0;
          this.nodeParent = null;
        } 
        if (this.draggingNode) {
          this.dragging = false;
          this.draggingNode = false;
          this.saveNode(this.selectedNode);
          this.removeLines();
        }
      },
      // =============== DRAGGING OPERATIONS =====================

      // =============== STYLING OPERATIONS =====================
      getNodeStyle(node) {
        return {left: node.position_x +'px', top: node.position_y +'px'}
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
      removeLines() {
        document.querySelectorAll("CANVAS").forEach((canvas) => {
          if(canvas.id != "map-canvas") {
            canvas.parentNode.removeChild(canvas)
          }
        })
      },
      // =============== STYLING OPERATIONS =====================


      // =============== Node CRUD OPERATIONS =====================
      saveNode(node) {
        if (this.nodeUpdatedFlag == false) { return; }
        if (!node || !node.id) { console.log("Unable to update node"); return; }

        this.nodeUpdatedFlag = false;
        let index = this.currentMindMap.nodes.findIndex((nod) => nod.id == node.id);
        if (index != -1) {
          node = this.currentMindMap.nodes[index]
          http.put(`/nodes/${node.id}.json`, {node: node}).then((res) => {
              this.stopWatch = true;
              this.currentMindMap.nodes.splice(index, 1, res.data.node);
          }).catch((error) => {
            console.log(error);
          })
        }
      },
      createNode(node) {
        node['mindmap_id'] = this.currentMindMap.id;
        http.post('/nodes.json', {node: node}).then((res) => {
          this.getMindmap(this.currentMindMap.id);
          this.selectedNode = res.data.node;
        }).catch((error) => {
          console.log(error);
        })
      },
      nodeUpdated(node) {
        this.nodeUpdatedFlag = true;
        this.stopWatch = true;
        this.saveNode(node);
      },
      deleteSelectedNode() {
        if (!this.selectedNode || !this.selectedNode.id) { return; }

        http.delete(`/nodes/${this.selectedNode.id}.json`).then((res) => {
          if (res.data.success) {
            this.selectedNode = null;
            this.getMindmap(this.currentMindMap.id);
          } else {
            console.log("Unable to delete node");
          }
        }).catch((error) => {
          console.log(error);
        })
      },
      // =============== Node CRUD OPERATIONS =====================

      // =============== Map CRUD OPERATIONS =====================
      saveCurrentMap(restore=false) {
        console.log("Came here");
        if (this.currentMindMap.id) {
          http.put(`/mindmaps/${this.currentMindMap.id}.json`, {mindmap: this.currentMindMap}).then((res) => {
            this.stopWatch = true;
            this.currentMindMap = res.data.mindmap;
            this.selectedNode = null;
            this.updateQuery();
          }).catch((error) => {
            console.log(error)
          })
        } else {
          http.post(`/mindmaps.json`, {mindmap: this.currentMindMap}).then((res) => {
            this.stopWatch = true;
            this.currentMindMap = res.data.mindmap;
            this.selectedNode = null;
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
        this.selectedNode = null;

        this.saveCurrentMap(true);
        this.$refs.resetMapModal.close();
      },
      // =============== Map CRUD OPERATIONS =====================

      // =============== OTHERS =====================
      updateQuery() {
        let query = {};
        query['key'] = this.currentMindMap.id;
        this.$router.push({query: query});
      },
      updateCentralIdea: _.debounce(
        function(input) {
          this.currentMindMap.name = this.$refs.central_idea.value;
        },
        500
      ),
      // =============== OTHERS =====================
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
      "currentMindMap.name": {
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
