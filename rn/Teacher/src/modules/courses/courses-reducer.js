// @flow

import { Reducer, Action, combineReducers } from 'redux'
import { handleActions } from 'redux-actions'
import CourseListActions from './actions'
import handleAsync from '../../utils/handleAsync'
import groupCustomColors from '../../api/utils/group-custom-colors'
import fromPairs from 'lodash/fromPairs'
import { tabs } from './tabs/tabs-reducer'

// dummy's to appease combineReducers
const course = (state) => (state || {})
const color = (state) => (state || '#FFFFFF00')

const courseContents: Reducer<CourseState, Action> = combineReducers({
  course,
  color,
  tabs,
})

const { refreshCourses } = CourseListActions

export const defaultState: CoursesState = {}

const emptyCourseState: CourseContentState = {
  tabs: { pending: 0, tabs: [] },
}

export const normalizeCourse = (course: Course, colors: { [courseId: string]: string }, prevState: CourseContentState = emptyCourseState): CourseState => {
  const { id } = course
  const color = colors[(id || 'none').toString()] || '#ff8'
  return {
    ...prevState,
    course,
    color,
  }
}

const coursesData: Reducer<CoursesState, any> = handleActions({
  [refreshCourses.toString()]: handleAsync({
    resolved: (state, [coursesResponse, colorsResponse]) => {
      const colors = groupCustomColors(colorsResponse.data).custom_colors.course
      const courses = coursesResponse.data
      const newStates = courses.map((course) => {
        return [course.id, normalizeCourse(course, colors, state[course.id])]
      })
      return fromPairs(newStates)
    },
  }),
}, defaultState)

export function courses (state: CoursesState = defaultState, action: Action): CoursesState {
  let newState = state
  if (action.payload && action.payload.courseID) {
    const courseID = action.payload.courseID
    const currentCourseState: CourseState = state[courseID]
    const courseState = courseContents(currentCourseState, action)
    newState = {
      ...state,
      [courseID]: courseState,
    }
  }
  return coursesData(newState, action)
}
