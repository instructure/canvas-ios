// @flow

import stateToProps from '../state-to-props'

const templates = {
  ...require('../../../redux/__templates__/app-state'),
}

test('finds the correct data', () => {
  let state = templates.appState({
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
      assignmentGroups: {},
      gradingPeriods: {},
    },
    favoriteCourses: {
      pending: 0,
    },
  })

  let data = stateToProps(state, { courseID: '2' })
  expect(data).toMatchObject({
    course: { id: 2 },
    color: '#333',
  })
})
