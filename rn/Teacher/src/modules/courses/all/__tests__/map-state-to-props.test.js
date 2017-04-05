// @flow

import mapStateToProps from '../map-state-to-props'
import { normalizeCourse } from '../../courses-reducer'
import * as courseTemplate from '../../../../api/canvas-api/__templates__/course'
import { appState } from '../../../../redux/__templates__/app-state'
import fromPairs from 'lodash/fromPairs'

describe('all courses mapStateToProps', () => {
  const a = courseTemplate.course({ id: 1, name: 'a' })
  const b = courseTemplate.course({ id: 2, name: 'b' })
  const c = courseTemplate.course({ id: 3, name: 'c' })
  const courseTemplates = [
    a, b, c,
  ]

  const colors: { [courseID: string]: string } = {
    '1': '#aaa',
    '2': '#bbb',
    '3': '#ccc',
    '4': '#ddd',
  }

  const courseStates: Array<CourseState> = courseTemplates
    .map((course) => normalizeCourse(course, colors))
  const pairs: Array<Array<*>> = courseStates
    .map((courseState) => ([courseState.course.id, courseState]))
  const courses: CoursesState = fromPairs(pairs)

  const state = appState({
    entities: {
      courses,
    },
  })

  const props = mapStateToProps(state)

  it('courses sorted alphabetically', () => {
    const expected = [a, b, c].map(course => ({ ...course, color: colors[course.id] }))
    expect(props.courses).toEqual(expected)
  })

  it('has colors', () => {
    expect(props.courses.map(course => course.color))
      .toEqual(['#aaa', '#bbb', '#ccc'])
  })
})
