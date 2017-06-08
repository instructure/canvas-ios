// @flow

import resetStoreKeys from '../reset-store-keys'

test('reset pending', () => {
  let object = {
    pending: 67,
  }
  object = resetStoreKeys(object)
  expect(object.pending).toEqual(0)
})
