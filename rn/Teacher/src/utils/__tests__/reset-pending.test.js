// @flow

import resetPending from '../reset-pending'

test('reset pending', () => {
  let object = {
    pending: 67,
  }
  object = resetPending(object)
  expect(object.pending).toEqual(0)
})

test('reset pending with blank object', () => {
  const object = resetPending(null)
  expect(object.pending).toEqual(0)
})
