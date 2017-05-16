// @flow
import mapStateToProps from '../map-state-to-props'
import { appState } from '../../../../redux/__templates__/app-state'

test('returns the correct props', () => {
  let state = appState({
    entities: {
      courses: {
        '1': {
          course: {
            name: 'trump university',
          },
        },
        '2': {
          course: {
            name: 'harvard',
          },
        },
      },
      assignmentGroups: {},
      gradingPeriods: {},
    },
    favoriteCourses: {
      courseRefs: ['1', '2'],
    },
  })
  let props = mapStateToProps(state)
  expect(props.courses).toEqual([state.entities.courses['2'].course, state.entities.courses['1'].course])
  expect(props.favorites).toEqual(state.favoriteCourses.courseRefs)
})
