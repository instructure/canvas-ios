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
      legoSets: { sets: [airplane], pending: 0 },
    },
  }

  expect(stateToProps(appState)).toEqual({ sets: [airplane], pending: 0 })
})
