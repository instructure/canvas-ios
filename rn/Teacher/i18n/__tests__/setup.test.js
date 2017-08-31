//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

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

