// @flow
import mapStateToProps from '../map-state-to-props'

test('returns the correct props', () => {
  let state = {
    entities: {
      courses: {
        '1': {
          course: {},
        },
      },
    },
    favoriteCourses: {
      courseRefs: ['1'],
    },
  }
  let props = mapStateToProps(state)
  expect(props.courses).toEqual([state.entities.courses['1'].course])
  expect(props.favorites).toEqual(state.favoriteCourses.courseRefs)
})
