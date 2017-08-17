/* @flow */

import mapStateToProps from '../map-state-to-props'

const template = {
  ...require('../../../../api/canvas-api/__templates__/course'),
  ...require('../../../../api/canvas-api/__templates__/tab'),
  ...require('../../../../redux/__templates__/app-state'),
}

test('mapStateToProps returns the correct props', () => {
  const course = template.course({ id: 1 })
  const tabs = { tabs: [template.tab()], pending: 0 }
  const attendanceTool = { pending: 0 }
  const state = template.appState({
    entities: {
      courses: {
        '1': {
          course,
          color: '#fff',
          tabs,
          attendanceTool,
        },
      },
    },
    favoriteCourses: {
      pending: 0,
      courseRefs: ['1'],
    },
  })
  const expected = {
    course,
    tabs: tabs.tabs,
    color: '#fff',
    pending: 0,
    error: undefined,
  }

  const props = mapStateToProps(state, { courseID: '1' })

  expect(props).toEqual(expected)
})

test('mapStateToProps throws without course', () => {
  const state: { [string]: any } = {
    entities: {
    },
    favoriteCourses: {},
  }

  expect(() => {
    mapStateToProps(state, { courseID: '1' })
  }).toThrow()
})
