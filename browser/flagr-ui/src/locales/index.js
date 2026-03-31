import Vue from 'vue'
import VueI18n from 'vue-i18n'

// Import Element UI locales
import elementEnLocale from 'element-ui/lib/locale/lang/en'
import elementZhLocale from 'element-ui/lib/locale/lang/zh-CN'

// Import custom locales
import enLocale from './en.json'
import zhLocale from './zh-CN.json'

Vue.use(VueI18n)

const messages = {
  en: {
    ...enLocale,
    ...elementEnLocale
  },
  'zh-CN': {
    ...zhLocale,
    ...elementZhLocale
  }
}

// Get saved language from localStorage or use default
const savedLang = localStorage.getItem('flagr-language') || 'en'

const i18n = new VueI18n({
  locale: savedLang,
  fallbackLocale: 'en',
  messages
})

export default i18n