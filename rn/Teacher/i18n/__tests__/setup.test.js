// @flow

import i18n from 'format-message'
import setup, { sanitizeLocale } from '../setup'

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
