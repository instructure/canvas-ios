// @flow

const { test, expect } = global
import LegoActions, {
  LEGOS_BUY_MOAR,
} from '../actions'

test('buy lego set action', () => {
  const set: LegoSet = {
    name: 'An Amazing Castle',
    imageURL: 'https://lego.com/castle',
  }

  expect(LegoActions.buyLegoSet(set)).toEqual({
    type: LEGOS_BUY_MOAR,
    sweetSweetLegoSet: set,
  })
})
