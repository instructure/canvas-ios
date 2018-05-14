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

/* eslint-disable flowtype/require-valid-file-annotation */

import { mapStateToProps } from '../Dashboard'
import { normalizeCourse } from '../../courses/courses-reducer'
import * as courseTemplate from '../../../__templates__/course'
import { enrollment } from '../../../__templates__/enrollments'
import { section } from '../../../__templates__/section'
import * as groupTemplate from '../../../__templates__/group'
import { appState } from '../../../redux/__templates__/app-state'
import fromPairs from 'lodash/fromPairs'
import App from '../../app/index'

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
  const a = courseTemplate.course({ id: 1, name: 'a', sections: [section()] })
  const b = courseTemplate.course({ id: 2, name: 'b', sections: [section()] })
  const c = courseTemplate.course({ id: 3, name: 'c', sections: [section()] })
  const d = courseTemplate.course({ id: 4, name: 'd', sections: [section()] })
  const courseTemplates = [a, b, c, d]
  const favorites = ['3', '1', '2']

  const courses = courseStates(courseTemplates)
  const state = appState({
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
  const a = courseTemplate.course({ id: 1, name: 'a', sections: [section()] })
  const b = courseTemplate.course({ id: 2, name: 'b', sections: [section()] })
  const courseTemplates = [a, b]

  const courses = courseStates(courseTemplates)
  const state = appState({
    favoriteCourses: { courseRefs: [] },
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

describe('mapStateToProps with student and observer enrollments', () => {
  const a = courseTemplate.course({ id: 1, name: 'a', enrollments: [studentEnrollment], sections: [section()] })
  const b = courseTemplate.course({ id: 2, name: 'b', enrollments: [observerEnrollment], sections: [section()] })
  const courseTemplates = [a, b]

  const courses = courseStates(courseTemplates)
  const state = appState({
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
  const a = courseTemplate.course({ id: 1, name: 'a', sections: [section()] })
  const b = courseTemplate.course({ id: 2, name: 'b', enrollments: [taEnrollment], sections: [section()] })
  const c = courseTemplate.course({ id: 3, name: 'c', enrollments: [designerEnrollment], sections: [section()] })
  const courseTemplates = [a, b, c]

  const courses = courseStates(courseTemplates)
  const state = appState({
    favoriteCourses: { courseRefs: ['1', '2', '3'] },
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
  const a = courseTemplate.course({ id: 1, name: 'a', sections: [section()] })
  const b = courseTemplate.course({ id: 2, name: 'b', enrollments: [studentEnrollment], sections: [section()] })
  const courseTemplates = [a, b]

  const courses = courseStates(courseTemplates)
  const state = appState({
    favoriteCourses: { courseRefs: ['1', '2'] },
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
  const a = courseTemplate.course({ id: 1, name: 'a', sections: [section()] })
  const b = courseTemplate.course({ id: 2, name: 'b', sections: [section()] })
  const c = courseTemplate.course({ id: 3, name: 'c', sections: [section()] })
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
  const a = courseTemplate.course({ id: 1, name: 'a', sections: [section()] })
  const b = courseTemplate.course({ id: 2, name: 'b', sections: [section()] })
  const courseTemplates = [a, b]
  const courseFavorites = ['1', '2']

  const groupA = groupTemplate.group({ id: '1', name: 'a', course_id: '1' })
  const groupB = groupTemplate.group({ id: '2', name: 'b', account_id: '1' })
  const groupC = groupTemplate.group({ id: '3', name: 'c', account_id: '1' })
  const groupFavorites = ['1', '2', '3']

  const courses = courseStates(courseTemplates)
  const state = appState({
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
  const sec1 = section({ course_id: '1', id: '1' })
  const sec2 = section({ course_id: '2', id: '2' })
  const sec3 = section({ course_id: '2', id: '3' })
  const sec4 = section({ course_id: '1' })
  const a = courseTemplate.course({ id: 1, name: 'a', sections: [sec4, sec1] })
  const b = courseTemplate.course({ id: 2, name: 'b', sections: [sec2, sec3] })
  const courseTemplates = [a, b]
  const favorites = ['1', '2']

  const courses = courseStates(courseTemplates)
  const state = appState({
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
  const a = courseTemplate.course({ id: 1, name: 'a', sections: [section()] })
  const b = courseTemplate.course({ id: 2, name: 'b', sections: [section()] })
  const c = courseTemplate.course({ id: 3, name: 'c', sections: [section()] })
  const d = courseTemplate.course({ id: 4, name: 'd', sections: [section()] })
  const courseTemplates = [a, b, c, d]
  const favorites = ['1', '2']

  const courses = courseStates(courseTemplates)
  const state = appState({
    favoriteCourses: { courseRefs: favorites },
    entities: {
      accountNotifications: { list: [] },
      courses,
      groups: {},
      enrollments: {
        '1': enrollment({ id: '1', course_id: '1', user_id: '1' }),
        '2': enrollment({ id: '2', course_id: '2', user_id: '1' }),
        '3': enrollment({ id: '3', course_id: '3', user_id: '2' }),
        '4': enrollment({ id: '4', course_id: '4', user_id: '3' }),
        '5': enrollment({ id: '5', course_id: '5', user_id: '1' }),
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
  it('all courses doesnt show invited or rejected', () => {
    let currentApp = App.current().appId
    App.setCurrentApp('student')

    const a = courseTemplate.course({ id: 1, name: 'a', sections: [section()], enrollments: [enrollment({ enrollment_state: 'invited' })] })
    const b = courseTemplate.course({ id: 2, name: 'b', sections: [section()], enrollments: [enrollment({ enrollment_state: 'rejected' })] })
    const c = courseTemplate.course({ id: 3, name: 'c', sections: [section()], enrollments: [enrollment({ enrollment_state: 'active' })] })
    const courseTemplates = [a, b, c]
    const favorites = ['3']

    const courses = courseStates(courseTemplates)
    const state = appState({
      favoriteCourses: { courseRefs: favorites },
      entities: {
        accountNotifications: { list: [] },
        courses,
        groups: {},
        enrollments: {},
      },
    })

    expect(mapStateToProps(false)(state).courses).toMatchObject([{ id: 3 }])
    App.setCurrentApp(currentApp)
  })
})
