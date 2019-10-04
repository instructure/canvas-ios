//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import { mapStateToProps } from '../Dashboard'
import { normalizeCourse } from '../../courses/courses-reducer'
import * as templates from '../../../__templates__'
import fromPairs from 'lodash/fromPairs'
import App from '../../app/index'

const colors: { [courseID: string]: string } = {
  '1': '#aaa',
  '2': '#bbb',
  '3': '#ccc',
  '4': '#ddd',
}

const taEnrollment = { type: 'ta', enrollment_state: 'active' }
const designerEnrollment = { type: 'designer', enrollment_state: 'active' }
const studentEnrollment = { type: 'student', enrollment_state: 'active' }
const observerEnrollment = { type: 'observer', enrollment_state: 'active' }

function courseStates (courseTemplates, positions = []): CoursesState {
  const states: Array<CourseState> = courseTemplates
    .map((course, i) => normalizeCourse(course, colors, {
      dashboardPosition: positions[i],
      enrollments: { refs: [] },
    }))
  states.forEach(state => { state.enrollments.refs.push('123') })
  const pairs: Array<Array<*>> = states
    .map((courseState) => ([courseState.course.id, courseState]))
  const courses: CoursesState = fromPairs(pairs)
  return courses
}

describe('mapStateToProps with dashboardPositions', () => {
  const a = templates.course({ id: 1, name: 'a', sections: [templates.section()] })
  const b = templates.course({ id: 2, name: 'b', sections: [templates.section()] })
  const c = templates.course({ id: 3, name: 'c', sections: [templates.section()] })
  const d = templates.course({ id: 4, name: 'd', sections: [templates.section()] })
  const courseTemplates = [a, b, c, d]
  const favorites = ['3', '1', '2']

  const courses = courseStates(courseTemplates, [0, 1, 2])
  const state = templates.appState({
    favoriteCourses: { courseRefs: favorites },
    entities: {
      accountNotifications: { list: [] },
      courses,
      groups: {},
      enrollments: {},
    },
  })

  const props = mapStateToProps(true)(state)

  it('has favorites', () => {
    expect(props.courses.length).toEqual(3)
  })

  it('sorts courses based on the dashboard position', () => {
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

  it('has hidden overlay setting', () => {
    expect(props.hideOverlays).toEqual(false)

    state.userInfo.userSettings.hide_dashcard_color_overlays = true
    expect(mapStateToProps(true)(state).hideOverlays).toEqual(true)

    state.userInfo.userSettings.hide_dashcard_color_overlays = false
    expect(mapStateToProps(true)(state).hideOverlays).toEqual(false)
  })
})

describe('mapStateToProps with no courses', () => {
  const state = templates.appState({
    favoriteCourses: { courseRefs: [] },
    entities: {
      accountNotifications: { list: [] },
      courses: {},
      groups: {},
      enrollments: {},
    },
  })
  const props = mapStateToProps(true)(state)

  it('has no courses', () => {
    expect(props.courses.length).toEqual(0)
  })

  it('has no course count', () => {
    expect(props.totalCourseCount).toEqual(0)
  })
})

describe('mapStateToProps with student and observer enrollments', () => {
  const a = templates.course({ id: 1, name: 'a', enrollments: [studentEnrollment], sections: [templates.section()] })
  const b = templates.course({ id: 2, name: 'b', enrollments: [observerEnrollment], sections: [templates.section()] })
  const courseTemplates = [a, b]

  const courses = courseStates(courseTemplates)
  const state = templates.appState({
    favoriteCourses: { courseRefs: ['1', '2'] },
    entities: {
      accountNotifications: { list: [] },
      courses,
      groups: {},
      enrollments: {},
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
  const a = templates.course({ id: 1, name: 'a', sections: [templates.section()] })
  const b = templates.course({ id: 2, name: 'b', enrollments: [taEnrollment], sections: [templates.section()] })
  const c = templates.course({ id: 3, name: 'c', enrollments: [designerEnrollment], sections: [templates.section()] })
  const courseTemplates = [a, b, c]

  const courses = courseStates(courseTemplates, [0, 1, 2])
  const state = templates.appState({
    entities: {
      accountNotifications: { list: [] },
      courses,
      groups: {},
      enrollments: {},
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
  const a = templates.course({ id: 1, name: 'a', sections: [templates.section()] })
  const b = templates.course({ id: 2, name: 'b', enrollments: [studentEnrollment], sections: [templates.section()] })
  const courseTemplates = [a, b]

  const courses = courseStates(courseTemplates, [0, 1])
  const state = templates.appState({
    entities: {
      accountNotifications: { list: [] },
      courses,
      groups: {},
      enrollments: {},
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
  const a = templates.course({ id: 1, name: 'a', sections: [templates.section()] })
  const b = templates.course({ id: 2, name: 'b', sections: [templates.section()] })
  const c = templates.course({ id: 3, name: 'c', sections: [templates.section()] })
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

  const state = templates.appState({
    entities: {
      accountNotifications: { list: [] },
      courses,
      groups: {},
      enrollments: {},
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
  const a = templates.course({ id: 1, name: 'a', sections: [templates.section()] })
  const b = templates.course({ id: 2, name: 'b', sections: [templates.section()] })
  const c = templates.course({ id: 3, name: 'c', access_restricted_by_date: true })
  const courseTemplates = [a, b, c]
  const courseFavorites = ['1', '2']

  const groupA = templates.group({ id: '1', name: 'a', course_id: '1' })
  const groupB = templates.group({ id: '2', name: 'b', account_id: '1' })
  const groupC = templates.group({ id: '3', name: 'c', account_id: '1' })
  const groupD = templates.group({ id: '4', name: 'd', course_id: '3' })
  const groupFavorites = ['1', '2', '3', '4']

  const courses = courseStates(courseTemplates)
  const state = templates.appState({
    favoriteCourses: { courseRefs: courseFavorites },
    favoriteGroups: { groupRefs: groupFavorites },
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
        '4': { group: groupD },
      },
      enrollments: {},
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
    }])
  })

  it('skips groups that are concluded', () => {
    let newState = {
      ...state,
      entities: {
        ...state.entities,
        groups: {
          ...state.entities.groups,
          '4': {
            concluded: true,
          },
        },
      },
    }
    expect(mapStateToProps(true)(newState).groups).toMatchObject([{
      id: '1',
    }, {
      id: '2',
    }, {
      id: '3',
    }])
  })

  it('skips groups for a concluded course', () => {
    let newState = {
      ...state,
      entities: {
        ...state.entities,
        groups: {
          ...state.entities.groups,
          '4': {
            concluded: false,
            course_id: 3,
          },
        },
      },
    }
    expect(mapStateToProps(true)(newState).groups).toMatchObject([{
      id: '1',
    }, {
      id: '2',
    }, {
      id: '3',
    }])
  })
})

describe('sections', () => {
  const sec1 = templates.section({ course_id: '1', id: '1' })
  const sec2 = templates.section({ course_id: '2', id: '2' })
  const sec3 = templates.section({ course_id: '2', id: '3' })
  const sec4 = templates.section({ course_id: '1' })
  const a = templates.course({ id: 1, name: 'a', sections: [sec4, sec1] })
  const b = templates.course({ id: 2, name: 'b', sections: [sec2, sec3] })
  const courseTemplates = [a, b]
  const favorites = ['1', '2']

  const courses = courseStates(courseTemplates)
  const state = templates.appState({
    favoriteCourses: { courseRefs: favorites },
    entities: {
      accountNotifications: { list: [] },
      courses,
      groups: {},
      enrollments: {},
    },
  })

  it('gets sections by id', () => {
    expect(mapStateToProps(true)(state).sections).toMatchObject({
      '1': { course_id: '1', id: '1' },
      '2': { course_id: '2', id: '2' },
      '3': { course_id: '2', id: '3' },
      '32': { course_id: '1', id: '32' },
    })
  })
})

describe('enrollments', () => {
  const a = templates.course({ id: 1, name: 'a', sections: [templates.section()] })
  const b = templates.course({ id: 2, name: 'b', sections: [templates.section()] })
  const c = templates.course({ id: 3, name: 'c', sections: [templates.section()] })
  const d = templates.course({ id: 4, name: 'd', sections: [templates.section()] })
  const courseTemplates = [a, b, c, d]
  const favorites = ['1', '2']

  const courses = courseStates(courseTemplates)
  const state = templates.appState({
    favoriteCourses: { courseRefs: favorites },
    entities: {
      accountNotifications: { list: [] },
      courses,
      groups: {},
      enrollments: {
        '1': templates.enrollment({ id: '1', course_id: '1', user_id: '1' }),
        '2': templates.enrollment({ id: '2', course_id: '2', user_id: '1' }),
        '3': templates.enrollment({ id: '3', course_id: '3', user_id: '2' }),
        '4': templates.enrollment({ id: '4', course_id: '4', user_id: '3' }),
        '5': templates.enrollment({ id: '5', course_id: '5', user_id: '1' }),
      },
    },
  })

  it('gets enrollments in an array', () => {
    expect(mapStateToProps(true)(state).enrollments).toMatchObject([
      { course_id: '1', id: '1' },
      { course_id: '2', id: '2' },
    ])
  })
})

describe('not full dashboard -- student', () => {
  let currentApp
  beforeAll(() => {
    currentApp = App.current().appId
    App.setCurrentApp('student')
  })
  afterAll(() => {
    App.setCurrentApp(currentApp)
  })

  it('all courses doesnt show invited or rejected', () => {
    const a = templates.course({ id: '1', name: 'a', sections: [templates.section()], enrollments: [templates.enrollment({ enrollment_state: 'invited' })] })
    const b = templates.course({ id: '2', name: 'b', sections: [templates.section()], enrollments: [templates.enrollment({ enrollment_state: 'rejected' })] })
    const c = templates.course({ id: '3', name: 'c', sections: [templates.section()], enrollments: [templates.enrollment({ enrollment_state: 'active' })] })
    const courseTemplates = [a, b, c]
    const favorites = ['3']

    const courses = courseStates(courseTemplates)
    const state = templates.appState({
      favoriteCourses: { courseRefs: favorites },
      entities: {
        accountNotifications: { list: [] },
        courses,
        groups: {},
        enrollments: {},
      },
    })

    expect(mapStateToProps(false)(state).courses).toMatchObject([{ id: '3' }])
  })

  it('all courses returns concluded courses', () => {
    const a = templates.course({ id: '1', name: 'a', end_at: new Date(0).toISOString(), sections: [templates.section()], enrollments: [templates.enrollment({ enrollment_state: 'concluded' })] })
    const courses = courseStates([a])
    const state = templates.appState({
      entities: {
        accountNotifications: { list: [] },
        courses,
        groups: {},
        enrollments: {},
      },
    })

    expect(mapStateToProps(false)(state).concludedCourses).toMatchObject([{ id: '1' }])
  })
})
