// @flow

import type {
  CourseListDataProps,
  CourseListActionProps,
  CourseListProps,
} from '../course-prop-types'

// tests to validate the types more than anything
test('should have CourseListDataProps', () => {
  const props: CourseListDataProps = {
    courses: [],
    customColors: {},
    pending: 0,
  }

  // must to appease Danger bot
  expect(props).toBeDefined()
})

test('should have CourseListActionProps', () => {
  const props: CourseListActionProps = {
    refreshCourses: () => {
      return Promise.all([])
    },
  }

  expect(props).toBeDefined()
})

test('should have a CourseListProps', () => {
  const data: CourseListDataProps = {
    courses: [],
    customColors: {},
    pending: 0,
  }

  const actions: CourseListActionProps = {
    refreshCourses: () => {
      return Promise.all([])
    },
  }

  const props: CourseListProps = { ...data, ...actions }
  expect(props).toBeDefined()
})
