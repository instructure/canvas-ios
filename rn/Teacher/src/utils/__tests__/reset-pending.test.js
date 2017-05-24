// @flow

import resetPending from '../reset-pending'

test('reset pending', () => {
  let object = {
    pending: 67,
  }
  object = resetPending(object)
  expect(object.pending).toEqual(0)
})
