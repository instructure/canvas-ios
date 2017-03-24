// @flow

import stateToProps from '../state-to-props'

test('finds the correct data', () => {
  let state = {
    entities: {
      courses: {
        '1': {
          course: { id: 1 },
          color: '#fff',
        },
        '2': {
          course: { id: 2 },
          color: '#333',
        },
      },
    },
  }

  let data = stateToProps(state, { courseID: '2' })
  expect(data).toMatchObject({
    course: { id: 2 },
    color: '#333',
  })
})
