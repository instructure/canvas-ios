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

import { CoursesActions } from '../actions'
import { CourseSettingsActions } from '../settings/actions'
import { EnrollmentsActions } from '../../enrollments/actions'
import { courses as coursesReducer } from '../courses-reducer'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'
import * as templates from '../../../__templates__'

describe('courses refresher', () => {
  it('should capture courses from response', async () => {
    const course = templates.course()
    const courses = [course]
    const customColors = templates.customColors()

    let action = CoursesActions({
      getCourses: apiResponse(courses),
      getCustomColors: apiResponse(customColors),
    }).refreshCourses()

    let state = await testAsyncReducer(coursesReducer, action)

    const expected: CourseState = {
      color: '#fff',
      course: course,
      pending: 0,
      tabs: {
        pending: 0,
        tabs: [],
      },
      assignmentGroups: {
        pending: 0,
        refs: [],
      },
      attendanceTool: {
        pending: 0,
      },
      enrollments: {
        pending: 0,
        refs: [],
      },
      quizzes: {
        pending: 0,
        refs: [],
      },
      discussions: {
        pending: 0,
        refs: [],
      },
      announcements: {
        pending: 0,
        refs: [],
      },
      groups: {
        pending: 0,
        refs: [],
      },
      enabledFeatures: [],
      gradingPeriods: {
        pending: 0,
        refs: [],
      },
      permissions: null,
    }
    expect(state).toEqual([{}, {
      [course.id]: expected,
    }])
  })

  it('puts in all courses', async () => {
    const course = templates.course()
    const nonTeacherCourse = { ...templates.course({ id: 991 }), enrollments: [] }
    const courses = [course, nonTeacherCourse]
    const customColors = templates.customColors()

    let action = CoursesActions({
      getCourses: apiResponse(courses),
      getCustomColors: apiResponse(customColors),
    }).refreshCourses()

    let state = await testAsyncReducer(coursesReducer, action)
    expect(state).toMatchSnapshot()
  })

  it('refresh courses with error', async () => {
    let action = CoursesActions({ getCourses: apiError({ message: 'no courses' }), getCustomColors: apiError({ message: 'no courses' }) }).refreshCourses()
    let state = await testAsyncReducer(coursesReducer, action)

    // the courses store doesn't track errors or pending
    expect(state).toEqual([{}, {}])
  })
})

describe('update custom color', () => {
  it('should change the color on pending', async () => {
    let action = CoursesActions({
      updateCourseColor: apiResponse({ hexcode: '#fff' }),
    }).updateCourseColor('1', '#fff')

    let defaultState = {
      '1': {
        color: '#333',
      },
    }

    let state = await testAsyncReducer(coursesReducer, action, defaultState)
    expect(state).toMatchObject([
      {
        '1': {
          color: '#fff',
          oldColor: '#333',
        },
      },
      {
        '1': {
          color: '#fff',
        },
      },
    ])
  })

  it('reverts the color when there is an error', async () => {
    let action = CoursesActions({
      updateCourseColor: apiError({ message: 'There was an error yo' }),
    }).updateCourseColor('1', '#fff')

    let defaultState = {
      '1': {
        color: '#333',
      },
    }

    let state = await testAsyncReducer(coursesReducer, action, defaultState)
    expect(state).toMatchObject([
      {
        '1': {
          color: '#fff',
          oldColor: '#333',
        },
      },
      {
        '1': {
          color: '#333',
        },
      },
    ])
  })
})

describe('update course', () => {
  let course
  let newCourse
  let defaultState

  beforeEach(() => {
    course = templates.course({
      id: '1',
      name: 'Old Name',
      default_view: 'wiki',
    })

    newCourse = {
      ...course,
      name: 'New Name',
      default_view: 'feed',
    }

    defaultState = {
      '1': {
        error: 'try again',
        course,
      },
    }
  })

  it('should update the course state', async () => {
    let api = {
      updateCourse: apiResponse({ ...newCourse }),
    }
    let action = CourseSettingsActions(api).updateCourse(newCourse, course)

    let state = await testAsyncReducer(coursesReducer, action, defaultState)

    expect(state).toMatchObject([
      {
        '1': {
          pending: 1,
          course: {
            name: 'New Name',
            default_view: 'feed',
          },
        },
      },
      {
        '1': {
          pending: 0,
          course: {
            name: 'New Name',
            default_view: 'feed',
          },
          error: null,
        },
      },
    ])
  })

  it('should update the course state with original name', async () => {
    let api = {
      updateCourse: apiResponse({ name: newCourse.name }),
    }
    let action = CourseSettingsActions(api).updateCourse(newCourse, course)

    let state = await testAsyncReducer(coursesReducer, action, defaultState)

    expect(state).toMatchObject([
      {
        '1': {
          pending: 1,
          course: {
            name: 'New Name',
            default_view: 'feed',
          },
        },
      },
      {
        '1': {
          pending: 0,
          course: {
            name: 'New Name',
            original_name: 'New Name',
            default_view: 'feed',
          },
          error: null,
        },
      },
    ])
  })

  it('should update the course state with differing name and original name', async () => {
    let api = {
      updateCourse: apiResponse({ original_name: newCourse.name, name: 'nickname' }),
    }
    let action = CourseSettingsActions(api).updateCourse(newCourse, course)

    let state = await testAsyncReducer(coursesReducer, action, defaultState)

    expect(state).toMatchObject([
      {
        '1': {
          pending: 1,
          course: {
            name: 'New Name',
            default_view: 'feed',
          },
        },
      },
      {
        '1': {
          pending: 0,
          course: {
            name: 'nickname',
            original_name: 'New Name',
            default_view: 'feed',
          },
          error: null,
        },
      },
    ])
  })

  it('should revert the course state on rejected', async () => {
    let api = {
      updateCourse: apiError({ message: 'error' }),
    }
    let action = CourseSettingsActions(api).updateCourse(newCourse, course)

    let state = await testAsyncReducer(coursesReducer, action, defaultState)

    expect(state).toMatchObject([
      {
        '1': {
          pending: 1,
          course: {
            name: 'New Name',
            default_view: 'feed',
          },
        },
      },
      {
        '1': {
          pending: 0,
          course: {
            name: 'Old Name',
            default_view: 'wiki',
          },
          error: 'error',
        },
      },
    ])
  })
})

describe('update course nickname', () => {
  let course
  let nickname = 'nickname'
  let defaultState

  beforeEach(() => {
    course = templates.course({
      id: '1',
      name: 'Old Name',
      default_view: 'wiki',
    })

    defaultState = {
      '1': {
        error: 'try again',
        course,
        pending: 0,
      },
    }
  })

  it('should update the course nickname', async () => {
    let api = {
      updateCourseNickname: apiResponse({ nickname, name: course.name }),
    }
    let action = CoursesActions(api).updateCourseNickname(course, nickname)
    let state = await testAsyncReducer(coursesReducer, action, defaultState)

    expect(state).toMatchObject([
      {
        '1': {
          pending: 1,
          course: {
            name: course.name,
          },
        },
      },
      {
        '1': {
          pending: 0,
          course: {
            name: nickname,
            original_name: course.name,
          },
          error: null,
        },
      },
    ])
  })
})

describe('getCourseEnabledFeature', () => {
  it('should set the store to pending when the action is called', () => {
    let action = {
      type: CoursesActions().getCourseEnabledFeatures.toString(),
      pending: true,
      payload: {
        courseID: '1',
      },
    }

    let newState = coursesReducer({}, action)
    expect(newState).toMatchObject({
      '1': {
        pending: 1,
      },
    })
  })

  it('should set the store not to pending whent the action is rejected', () => {
    let action = {
      type: CoursesActions().getCourseEnabledFeatures.toString(),
      error: true,
      payload: {
        courseID: '1',
      },
    }

    let state = {
      '1': {
        pending: 1,
      },
    }
    let newState = coursesReducer(state, action)
    expect(newState).toMatchObject({
      '1': {
        pending: 0,
      },
    })
  })

  it('should set the enabledFeatures on the course when it is successful', () => {
    let action = {
      type: CoursesActions().getCourseEnabledFeatures.toString(),
      payload: {
        courseID: '1',
        result: {
          data: ['anonymous_grading'],
        },
      },
    }

    let state = {
      '1': {
        pending: 1,
      },
    }
    let newState = coursesReducer(state, action)
    expect(newState).toMatchObject({
      '1': {
        pending: 0,
        enabledFeatures: ['anonymous_grading'],
      },
    })
  })
})

describe('getCoursePermissions', () => {
  it('should set the permissions on the course', () => {
    let action = {
      type: CoursesActions().getCoursePermissions.toString(),
      payload: {
        courseID: '1',
        result: {
          data: { send_messages: false },
        },
      },
    }

    let state = {
      '1': {},
    }
    let newState = coursesReducer(state, action)
    expect(newState).toMatchObject({
      '1': {
        permissions: { send_messages: false },
      },
    })
  })
})

describe('refresh single course', () => {
  it('no existing permissions', () => {
    let action = {
      type: CoursesActions().refreshCourse.toString(),
      payload: {
        result: {
          data: {
            permissions: {
              create_announcement: true,
              create_discussion_topic: true,
            }
            ,
          },
        },
        context: 'courses',
        contextID: '1',
      },
    }

    let state = {}
    let newState = coursesReducer(state, action)
    expect(newState).toMatchObject(
      {
        '1': {
          'announcements': { 'pending': 0, 'refs': [] },
          'assignmentGroups': { 'pending': 0, 'refs': [] },
          'attendanceTool': { 'pending': 0 },
          'color': '#FFFFFF00',
          'course': {},
          'discussions': { 'pending': 0, 'refs': [] },
          'enabledFeatures': [],
          'enrollments': { 'pending': 0, 'refs': [] },
          'error': null,
          'gradingPeriods': { 'pending': 0, 'refs': [] },
          'groups': { 'pending': 0, 'refs': [] },
          'oldColor': '#FFFFFF00',
          'pending': 0,
          'permissions': {},
          'quizzes': { 'pending': 0, 'refs': [] },
          'tabs': { 'pending': 0, 'tabs': [] },
        },
        'undefined': { 'permissions': { 'create_announcement': true, 'create_discussion_topic': true } },
      }
    )
  })

  it('existing permissions', () => {
    let action = {
      type: CoursesActions().refreshCourse.toString(),
      payload: {
        result: {
          data: {
            permissions: {
              create_announcement: false,
              create_discussion_topic: true,
            }
            ,
          },
        },
        context: 'courses',
        contextID: '1',
      },
    }

    let state = {
      '1': {
        'announcements': { 'pending': 0, 'refs': [] },
        'assignmentGroups': { 'pending': 0, 'refs': [] },
        'attendanceTool': { 'pending': 0 },
        'color': '#FFFFFF00',
        'course': {},
        'discussions': { 'pending': 0, 'refs': [] },
        'enabledFeatures': [],
        'enrollments': { 'pending': 0, 'refs': [] },
        'error': null,
        'gradingPeriods': { 'pending': 0, 'refs': [] },
        'groups': { 'pending': 0, 'refs': [] },
        'oldColor': '#FFFFFF00',
        'pending': 0,
        'permissions': {},
        'quizzes': { 'pending': 0, 'refs': [] },
        'tabs': { 'pending': 0, 'tabs': [] },
      },
      'undefined': { 'permissions': { 'create_announcement': false, 'create_discussion_topic': true } },
    }
    let newState = coursesReducer(state, action)
    expect(newState).toMatchObject(
      {
        '1': {
          'announcements': { 'pending': 0, 'refs': [] },
          'assignmentGroups': { 'pending': 0, 'refs': [] },
          'attendanceTool': { 'pending': 0 },
          'color': '#FFFFFF00',
          'course': {},
          'discussions': { 'pending': 0, 'refs': [] },
          'enabledFeatures': [],
          'enrollments': { 'pending': 0, 'refs': [] },
          'error': null,
          'gradingPeriods': { 'pending': 0, 'refs': [] },
          'groups': { 'pending': 0, 'refs': [] },
          'oldColor': '#FFFFFF00',
          'pending': 0,
          'permissions': {},
          'quizzes': { 'pending': 0, 'refs': [] },
          'tabs': { 'pending': 0, 'tabs': [] },
        },
        'undefined': { 'permissions': { 'create_announcement': false, 'create_discussion_topic': true } },
      }
    )
  })
})

describe('refresh users courses', () => {
  it('should add the refs to the right course', () => {
    let action = {
      type: EnrollmentsActions().refreshUserEnrollments.toString(),
      payload: {
        result: {
          data: [
            templates.enrollment({ id: '1', course_id: '1' }),
            templates.enrollment({ id: '2', course_id: '2' }),
          ],
        },
      },
    }

    let state = {
      '1': {},
      '2': {},
    }

    let newState = coursesReducer(state, action)
    expect(newState).toMatchObject({
      '1': {
        enrollments: {
          refs: ['1'],
        },
      },
      '2': {
        enrollments: {
          refs: ['2'],
        },
      },
    })
  })

  it('should create initial course state if no course is present', () => {
    let action = {
      type: EnrollmentsActions().refreshUserEnrollments.toString(),
      payload: {
        result: {
          data: [
            templates.enrollment({ id: '1', course_id: '1' }),
          ],
        },
      },
    }

    let state = {}
    let newState = coursesReducer(state, action)
    expect(newState).toMatchObject({
      '1': {
        enrollments: {
          refs: ['1'],
        },
      },
    })
    expect(newState['1'].color).not.toBeUndefined()
  })
})
