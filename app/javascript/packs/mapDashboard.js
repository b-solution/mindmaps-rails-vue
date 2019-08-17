import Mindmap from 'components/mindmaps/mindmap.vue';
import router from 'routers/mindmaps'

// eslint-disable-next-line no-unused-vars
const mindmapApp = new Vue({
  router,
  el: '#mapDashboard',
  template: '<Mindmap />',
  components: { Mindmap }
});
