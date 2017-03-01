// @flow

const { test, expect } = global
import { stateToProps } from '../props'
import type { AppState } from '../props'

test('stateToProps', () => {
  const airplane: LegoSet = {
    name: 'City Airplane',
    imageURL: 'https://lego.com/airplane',
  }
  const appState: AppState = {
    toys: {
      legoSets: [airplane],
    },
  }

  expect(stateToProps(appState)).toEqual({ legoSets: [airplane] })
})
