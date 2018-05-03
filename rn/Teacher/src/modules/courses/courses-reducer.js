//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import { Reducer, Action, combineReducers } from 'redux'
import { handleActions } from 'redux-actions'
import CourseListActions, { UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION } from './actions'
import CourseSettingsActions from './settings/actions'
import EnrollmentsActions from '../enrollments/actions'
import handleAsync from '../../utils/handleAsync'
import { parseErrorMessage } from '../../redux/middleware/error-handler'
import groupCustomColors from '../../utils/group-custom-colors'
import fromPairs from 'lodash/fromPairs'
import { tabs } from './tabs/tabs-reducer'
import { assignmentGroups } from '../assignments/assignment-group-refs-reducer'
import { enrollments } from '../enrollments/enrollments-refs-reducer'
import { refs as quizzes } from '../quizzes/reducer'
import { refs as discussions } from '../discussions/reducer'
import { refs as announcements } from '../announcements/reducer'
import attendanceTool from '../external-tools/attendance-tool-reducer'
import groups from '../groups/group-refs-reducer'
import { refs as gradingPeriods } from '../assignments/grading-periods-reducer'

// dummy's to appease combineReducers
const course = (state) => (state || {})
const color = (state) => (state || '#FFFFFF00')
const pending = (state) => (state || 0)
const error = (state) => (state || null)
const enabledFeatures = (state) => (state || [])
const permissions = (state) => (state || {})

const courseContents: Reducer<CourseState, Action> = combineReducers({
  course,
  color,
  tabs,
  assignmentGroups,
  oldColor: color,
  pending,
  error,
  enrollments,
  quizzes,
  discussions,
  announcements,
  groups,
  attendanceTool,
  enabledFeatures,
  gradingPeriods,
  permissions,
})
const { refreshCourses, refreshCourse, updateCourseColor, getCourseEnabledFeatures, getCoursePermissions, updateCourseNickname } = CourseListActions
const { updateCourse } = CourseSettingsActions

export const defaultState: { [courseID: string]: CourseState & CourseContentState } = {}

const emptyCourseState: CourseContentState = {
  tabs: { pending: 0, tabs: [] },
  assignmentGroups: { pending: 0, refs: [] },
  enrollments: { pending: 0, refs: [] },
  quizzes: { pending: 0, refs: [] },
  discussions: { pending: 0, refs: [] },
  announcements: { pending: 0, refs: [] },
  groups: { pending: 0, refs: [] },
  attendanceTool: { pending: 0 },
  enabledFeatures: [],
  gradingPeriods: { pending: 0, refs: [] },
  permissions: null,
}

export const normalizeCourse = (course: Course, colors: { [courseId: string]: string } = {}, prevState: CourseContentState = emptyCourseState): CourseState => {
  const { id } = course
  const color = colors[id] || '#aaa'
  return {
    ...prevState,
    course,
    color,
    pending: 0,
  }
}

const coursesData: Reducer<CoursesState, any> = handleActions({
  [refreshCourses.toString()]: handleAsync({
    resolved: (state, { result: [coursesResponse, colorsResponse] }) => {
      const colors = groupCustomColors(colorsResponse.data).custom_colors.course
      const courses = coursesResponse.data
      const newStates = courses.map((course) => {
        return [course.id, normalizeCourse(course, colors, state[course.id])]
      })
      return fromPairs(newStates)
    },
  }),
  [updateCourseColor.toString()]: handleAsync({
    pending: (state, { courseID, color }) => {
      return {
        ...state,
        [courseID]: {
          ...state[courseID],
          color,
          oldColor: state[courseID].color,
          pending: state[courseID].pending + 1,
          error: null,
        },
      }
    },
    resolved: (state, { courseID }) => {
      let courseState = { ...state[courseID] }
      delete courseState.oldColor
      courseState.pending--
      courseState.error = null
      return {
        ...state,
        [courseID]: courseState,
      }
    },
    rejected: (state, { courseID, error }) => {
      let courseState = { ...state[courseID] }
      courseState.color = courseState.oldColor
      delete courseState.oldColor
      courseState.pending--
      return {
        ...state,
        [courseID]: courseState,
      }
    },
  }),
  [updateCourse.toString()]: handleAsync({
    pending: (state, { course }) => {
      return {
        ...state,
        [course.id]: {
          ...state[course.id],
          course,
          pending: state[course.id].pending + 1,
          error: null,
        },
      }
    },
    resolved: (state, { result, course }) => {
      let originalName = result.data.original_name || result.data.name
      return {
        ...state,
        [course.id]: {
          ...state[course.id],
          course: { ...course, name: result.data.name, original_name: originalName },
          pending: state[course.id].pending - 1,
          error: null,
        },
      }
    },
    rejected: (state, { oldCourse, error }) => {
      return {
        ...state,
        [oldCourse.id]: {
          ...state[oldCourse.id],
          course: oldCourse,
          error: parseErrorMessage(error),
          pending: state[oldCourse.id].pending - 1,
        },
      }
    },
  }),
  [updateCourseNickname.toString()]: handleAsync({
    pending: (state, { course }) => {
      return {
        ...state,
        [course.id]: {
          ...state[course.id],
          pending: state[course.id].pending + 1,
          error: null,
        },
      }
    },
    resolved: (state, { result, course, nickname }) => {
      let courseState = state[course.id] || {}
      course = { ...courseState.course || {} }
      course.name = nickname
      course.original_name = result.data.name
      return {
        ...state,
        [course.id]: {
          ...courseState,
          course,
          pending: state[course.id].pending - 1,
          error: null,
        },
      }
    },
    rejected: (state, { course, error }) => {
      return {
        ...state,
        [course.id]: {
          ...state[course.id],
          pending: state[course.id].pending - 1,
          error: parseErrorMessage(error),
        },
      }
    },
  }),
  [getCourseEnabledFeatures.toString()]: handleAsync({
    pending: (state, { courseID }) => {
      return {
        ...state,
        [courseID]: {
          ...state[courseID],
          pending: state[courseID].pending + 1,
        },
      }
    },
    rejected: (state, { courseID }) => {
      return {
        ...state,
        [courseID]: {
          ...state[courseID],
          pending: state[courseID].pending - 1,
        },
      }
    },
    resolved: (state, payload) => {
      let { courseID, result } = payload
      return {
        ...state,
        [courseID]: {
          ...state[courseID],
          pending: state[courseID].pending - 1,
          enabledFeatures: result.data,
        },
      }
    },
  }),
  [getCoursePermissions.toString()]: handleAsync({
    resolved: (state, { result, courseID }) => {
      return {
        ...state,
        [courseID]: {
          ...state[courseID],
          permissions: result.data,
        },
      }
    },
  }),
  [EnrollmentsActions.refreshUserEnrollments.toString()]: handleAsync({
    resolved: (state, { result }) => {
      let enrollments = result.data
      if (!enrollments) return state

      return enrollments.reduce((nextState, enrollment) => {
        let courseID = enrollment.course_id
        // it's possible for this call to happen before courses are available
        let course = nextState[courseID] || courseContents(undefined, {})
        let refs = new Set(course && course.enrollments && course.enrollments.refs || [])
        refs.add(enrollment.id)
        nextState[courseID] = {
          ...course,
          enrollments: {
            ...course.enrollments,
            refs: [...refs],
          },
        }
        return nextState
      }, { ...state })
    },
  }),
  [refreshCourse.toString()]: handleAsync({
    resolved: (state, { result, courseID }) => {
      return {
        ...state,
        [courseID]: {
          ...state[courseID],
          permissions: { ...(state[courseID] && state[courseID].permissions || {}), ...result.data.permissions },
        },
      }
    },
  }),
}, defaultState)

export function courses (state: CoursesState = defaultState, action: Action): CoursesState {
  let newState = state
  if (action.payload && (action.payload.courseID || action.payload.context === 'courses' && action.payload.contextID)) {
    const courseID = action.payload.courseID || action.payload.contextID
    const currentCourseState: CourseState = state[courseID]
    const courseState = courseContents(currentCourseState, action)
    newState = {
      ...state,
      [courseID]: courseState,
    }
  }
  return coursesData(newState, action)
}

export function courseDetailsTabSelectedRow (state: CourseDetailsTabSelectedRowState = { rowID: '' }, action: Action): CourseDetailsTabSelectedRowState {
  if (action.type === UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION) {
    const rowID = action.payload.rowID
    return {
      ...state,
      ...{ rowID },
    }
  }
  return state
}
