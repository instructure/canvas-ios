// @flow

import i18n from 'format-message'
import setup, { sanitizeLocale, initMoment } from '../setup'
import moment from 'moment'

test('locale setup should work', () => {
  const mock = jest.fn()
  i18n.setup = mock
  setup('en_US')
  expect(mock).toBeCalled()
})

test('sanitize apple locale should work', () => {
  const sanitized = sanitizeLocale('en_US')
  expect(sanitized).toEqual('en-US')
})

test('moment should get the right language', () => {
  const locales = ['ar', 'da', 'de', 'en-au', 'en-gb', 'es', 'fr-ca', 'fr', 'ja', 'mi', 'nb', 'nl', 'pl', 'pt-br', 'pt', 'ru', 'sv', 'zh-hk', 'zh']
  expect(locales.length).toEqual(19)
  locales.forEach((locale) => {
    initMoment(locale)
    if (locale === 'zh') {
      expect(moment.locale()).toEqual('zh-cn')
    } else {
      expect(moment.locale()).toEqual(locale)
    }
  })
})

