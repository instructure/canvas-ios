// @flow

import mapStateToProps from '../map-state-to-props'

test('mapStateToProps returns just the courses sub reducer', () => {
  let storeState = {
    courses: {},
  }
  let state = mapStateToProps(storeState)
  expect(state).toEqual(storeState.courses)
})
