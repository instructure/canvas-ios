//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// @flow

import { mapStateToProps } from '../Dashboard'
import { normalizeCourse } from '../../courses/courses-reducer'
import * as courseTemplate from '../../../__templates__/course'
import * as groupTemplate from '../../../__templates__/group'
import { appState } from '../../../redux/__templates__/app-state'
import fromPairs from 'lodash/fromPairs'

const colors: { [courseID: string]: string } = {
  '1': '#aaa',
  '2': '#bbb',
  '3': '#ccc',
  '4': '#ddd',
}

const taEnrollment = { type: 'ta' }
const designerEnrollment = { type: 'designer' }
const studentEnrollment = { type: 'student' }
const observerEnrollment = { type: 'observer' }

function courseStates (courseTemplates): CoursesState {
  const states: Array<CourseState> = courseTemplates
    .map((course) => normalizeCourse(course, colors))
  const pairs: Array<Array<*>> = states
    .map((courseState) => ([courseState.course.id, courseState]))
  const courses: CoursesState = fromPairs(pairs)
  return courses
}

describe('mapStateToProps with favorites', () => {
  const a = courseTemplate.course({ id: 1, name: 'a' })
  const b = courseTemplate.course({ id: 2, name: 'b' })
  const c = courseTemplate.course({ id: 3, name: 'c' })
  const d = courseTemplate.course({ id: 4, name: 'd' })
  const courseTemplates = [a, b, c, d]
  const favorites = ['3', '1', '2']

  const courses = courseStates(courseTemplates)
  const state = appState({
    favoriteCourses: { courseRefs: favorites },
    entities: {
      accountNotifications: { list: [] },
      courses,
      groups: {},
    },
  })

  const props = mapStateToProps(true)(state)

  it('has favorites', () => {
    expect(props.courses.length).toEqual(favorites.length)
  })

  it('sorts courses alphabetically', () => {
    const expected = [a, b, c].map(course => ({ ...course, color: colors[course.id] }))
    expect(props.courses).toEqual(expected)
  })

  it('has colors', () => {
    expect(props.courses.map(course => course.color))
      .toEqual(['#aaa', '#bbb', '#ccc'])
  })

  it('has course count', () => {
    expect(props.totalCourseCount).toEqual(courseTemplates.length)
  })
})

describe('mapStateToProps with no favorites', () => {
  const a = courseTemplate.course({ id: 1, name: 'a' })
  const b = courseTemplate.course({ id: 2, name: 'b' })
  const courseTemplates = [a, b]

  const courses = courseStates(courseTemplates)
  const state = appState({
    favoriteCourses: { courseRefs: [] },
    entities: {
      accountNotifications: { list: [] },
      courses,
      groups: {},
    },
  })

  const props = mapStateToProps(true)(state)

  it('has no favorites', () => {
    expect(props.courses.length).toEqual(0)
  })

  it('has course count', () => {
    expect(props.totalCourseCount).toEqual(courseTemplates.length)
  })
})

describe('mapStateToProps with no courses', () => {
  const state = appState({
    favoriteCourses: { courseRefs: [] },
    entities: {
      accountNotifications: { list: [] },
      courses: {},
      groups: {},
    },
  })
  const props = mapStateToProps(true)(state)

  it('has no favorites', () => {
    expect(props.courses.length).toEqual(0)
  })

  it('has no course count', () => {
    expect(props.totalCourseCount).toEqual(0)
  })
})

describe('mapStateToProps with student and observer enrollments', () => {
  const a = courseTemplate.course({ id: 1, name: 'a', enrollments: [studentEnrollment] })
  const b = courseTemplate.course({ id: 2, name: 'b', enrollments: [observerEnrollment] })
  const courseTemplates = [a, b]

  const courses = courseStates(courseTemplates)
  const state = appState({
    favoriteCourses: { courseRefs: ['1', '2'] },
    entities: {
      accountNotifications: { list: [] },
      courses,
      groups: {},
    },
  })

  const props = mapStateToProps(true)(state)

  it('has no favorites', () => {
    expect(props.courses.length).toEqual(0)
  })

  it('has no course count', () => {
    expect(props.totalCourseCount).toEqual(0)
  })
})

describe('mapStateToProps with various teacher enrollments', () => {
  const a = courseTemplate.course({ id: 1, name: 'a' })
  const b = courseTemplate.course({ id: 2, name: 'b', enrollments: [taEnrollment] })
  const c = courseTemplate.course({ id: 3, name: 'c', enrollments: [designerEnrollment] })
  const courseTemplates = [a, b, c]

  const courses = courseStates(courseTemplates)
  const state = appState({
    favoriteCourses: { courseRefs: ['1', '2', '3'] },
    entities: {
      accountNotifications: { list: [] },
      courses,
      groups: {},
    },
  })

  const props = mapStateToProps(true)(state)

  it('has favorites', () => {
    expect(props.courses.length).toEqual(courseTemplates.length)
  })

  it('has course count', () => {
    expect(props.totalCourseCount).toEqual(courseTemplates.length)
  })
})

describe('mapStateToProps with teacher and student enrollments', () => {
  const a = courseTemplate.course({ id: 1, name: 'a' })
  const b = courseTemplate.course({ id: 2, name: 'b', enrollments: [studentEnrollment] })
  const courseTemplates = [a, b]

  const courses = courseStates(courseTemplates)
  const state = appState({
    favoriteCourses: { courseRefs: ['1', '2'] },
    entities: {
      accountNotifications: { list: [] },
      courses,
      groups: {},
    },
  })

  const props = mapStateToProps(true)(state)

  it('has 1 favorite', () => {
    expect(props.courses.length).toEqual(1)
  })

  it('has 1 course count', () => {
    expect(props.totalCourseCount).toEqual(1)
  })
})

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
      accountNotifications: { list: [] },
      courses,
      groups: {},
    },
  })

  const props = mapStateToProps(false)(state)

  it('courses sorted alphabetically', () => {
    const expected = [a, b, c].map(course => ({ ...course, color: colors[course.id] }))
    expect(props.courses).toEqual(expected)
  })

  it('has colors', () => {
    expect(props.courses.map(course => course.color))
      .toEqual(['#aaa', '#bbb', '#ccc'])
  })
})

describe('groups', () => {
  const a = courseTemplate.course({ id: 1, name: 'a' })
  const b = courseTemplate.course({ id: 2, name: 'b' })
  const courseTemplates = [a, b]
  const favorites = ['1', '2']

  const groupA = groupTemplate.group({ id: '1', name: 'a', course_id: '1' })
  const groupB = groupTemplate.group({ id: '2', name: 'b', account_id: '1' })
  const groupC = groupTemplate.group({ id: '3', name: 'c', account_id: '1' })

  const courses = courseStates(courseTemplates)
  const state = appState({
    favoriteCourses: { courseRefs: favorites },
    entities: {
      accountNotifications: { list: [] },
      courses,
      groups: {
        '1': {
          group: groupA,
          color: '#fff',
        },
        '2': {
          group: groupB,
          color: '#eee',
        },
        '3': { group: groupC },
      },
    },
  })

  it('gets all groups', () => {
    expect(mapStateToProps(true)(state).groups).toMatchObject([{
      id: '1',
      name: 'a',
      contextName: 'a',
      term: 'Default Term',
      color: '#fff',
    }, {
      id: '2',
      name: 'b',
      contextName: 'Account Group',
      color: '#eee',
    }, {
      id: '3',
      name: 'c',
      contextName: 'Account Group',
      color: '#7F91A7',
    }])
  })

  it('skips over groups that have a color but no group yet', () => {
    let newState = {
      ...state,
      entities: {
        ...state.entities,
        groups: {
          ...state.entities.groups,
          '4': {
            color: '#fff',
          },
        },
      },
    }
    expect(mapStateToProps(true)(newState).groups).toMatchObject([{
      id: '1',
      name: 'a',
      contextName: 'a',
      term: 'Default Term',
      color: '#fff',
    }, {
      id: '2',
      name: 'b',
      contextName: 'Account Group',
      color: '#eee',
    }, {
      id: '3',
      name: 'c',
      contextName: 'Account Group',
      color: '#7F91A7',
    }])
  })
})
