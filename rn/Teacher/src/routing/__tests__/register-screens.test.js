// @flow

import { wrap } from '../register-screens'

test('register screens', () => {
  var component = 'silly component'
  var func = wrap(component)
  expect(func()).toEqual(component)
})
