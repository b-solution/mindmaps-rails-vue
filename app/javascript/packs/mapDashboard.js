import Mindmap from 'components/mindmaps/mindmap.vue';

// eslint-disable-next-line no-unused-vars
const mindmapApp = new Vue({
  el: '#mapDashboard',
  components: { Mindmap },
  template: '<Mindmap />',
  replace: false
});
