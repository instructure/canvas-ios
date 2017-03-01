// @flow

const { test, expect } = global
import legoSets from '../reducer'
import { buyLegoSet } from '../actions'
import { Action } from 'redux'

test('reduce buy moar legos', () => {
  const noLegos: LegoSet[] = []
  const set: LegoSet = {
    name: 'Freight Train',
    imageURL: 'https://legos.com/train',
  }
  const action: Action = buyLegoSet(set)

  expect(legoSets(noLegos, action)).toEqual([
    set,
  ])
})
