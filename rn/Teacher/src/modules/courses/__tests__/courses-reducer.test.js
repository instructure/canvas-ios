// @flow

import { CoursesActions } from '../actions'
import { CourseSettingsActions } from '../settings/actions'
import { courses as coursesReducer } from '../courses-reducer'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'
import * as courseTemplate from '../../../api/canvas-api/__templates__/course'

describe('courses refresher', () => {
  it('should capture courses from response', async () => {
    const course = courseTemplate.course()
    const courses = [course]
    const customColors = courseTemplate.customColors()

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

    }
    expect(state).toEqual([{}, {
      [course.id]: expected,
    }])
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
    course = courseTemplate.course({
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
      updateCourse: apiResponse(),
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
