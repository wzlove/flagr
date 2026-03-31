// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'

import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'

import App from './App.vue'
import router from './router'
import i18n from './locales'

Vue.config.productionTip = false
Vue.use(ElementUI)

// Autofocus certain fields
Vue.directive('focus', {
  inserted: function (el) {
    el.__vue__.focus()
  }
})

/* eslint-disable no-new */

new Vue({
  i18n,
  render: h => h(App),
  router
}).$mount('#app')