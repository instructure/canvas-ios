/* @flow */

import i18n from 'format-message'
import generateId from 'format-message-generate-id/underscored_crc32'
import translations from './locales/index'
import moment from 'moment'
require('moment/locale/de')

export function sanitizeLocale (locale: string): string {
  return locale.replace('_', '-')
}

export default function (locale: string): void {
  const sanitizedLocale = sanitizeLocale(locale)
  console.log('Starting up the app with the following locale: ' + locale)
  i18n.setup({
    locale: sanitizedLocale,
    generateId,
    translations,
  })
  initMoment(sanitizedLocale)
}

function initMoment (locale: string): void {
  switch (locale) {
    case 'ar':
      require('moment/locale/ar')
      break
    case 'da':
      require('moment/locale/da')
      break
    case 'de':
      require('moment/locale/da')
      break
    case 'en-au':
      require('moment/locale/en-au')
      break
    case 'en-gb':
      require('moment/locale/en-gb')
      break
    case 'es':
      require('moment/locale/es')
      break
    case 'fr-ca':
      require('moment/locale/fr-ca')
      break
    case 'fr':
      require('moment/locale/fr')
      break
    // Bummer, they don't support haitian... :(
    // case 'ht':
    //   require('moment/locale/ht')
    //   break
    case 'ja':
      require('moment/locale/ja')
      break
    case 'mi':
      require('moment/locale/mi')
      break
    case 'nb':
      require('moment/locale/nb')
      break
    case 'nl':
      require('moment/locale/nl')
      break
    case 'pl':
      require('moment/locale/pl')
      break
    case 'pt-br':
      require('moment/locale/pt-br')
      break
    case 'pt':
      require('moment/locale/pt')
      break
    case 'ru':
      require('moment/locale/ru')
      break
    case 'sv':
      require('moment/locale/sv')
      break
    case 'zh-hk':
      require('moment/locale/zh-hk')
      break
    case 'zh':
      require('moment/locale/zh-cn')
      break
  }

  moment.locale(locale)
}
