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

// @flow

import { createAction } from 'redux-actions'
import canvas from '../../canvas-api'

export const UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION: string = 'course-details.selected-tab.selected-row'

export let CoursesActions = (api: CanvasApi): * => ({
  refreshCourses: createAction('courses.refresh', () => ({
    promise: Promise.all([
      api.getCourses(),
      api.getCustomColors(),
    ]),
    syncToNative: true,
  })),
  refreshCourse: createAction('course.refresh', (courseID: string) => {
    return {
      promise: Promise.all([
        api.getCourse(courseID),
        api.getCustomColors(),
      ]),
      courseID,
    }
  }),
  updateCourseColor: createAction('courses.updateColor', (courseID: string, color: string) => {
    return {
      courseID,
      color,
      promise: api.updateCourseColor(courseID, color),
      syncToNative: true,
    }
  }),
  refreshGradingPeriods: createAction('courses.refreshGradingPeriods', (courseID: string) => {
    return {
      promise: api.getCourseGradingPeriods(courseID),
      handlesError: true,
      courseID,
    }
  }),
  getCourseEnabledFeatures: createAction('courses.getCourseEnabledFeatures', (courseID: string) => {
    return {
      promise: api.getCourseEnabledFeatures(courseID),
      courseID,
    }
  }),
  getCoursePermissions: createAction('courses.getPermissions', (courseID: string) => {
    return {
      promise: api.getCoursePermissions(courseID),
      courseID,
    }
  }),
  getCourseSettings: createAction('courses.getSettings', (courseID: string) => ({
    promise: api.getCourseSettings(courseID),
    courseID,
  })),
  updateCourseNickname: createAction('courses.update-nickname', (course: Course, nickname: string) => ({
    course,
    nickname,
    promise: api.updateCourseNickname(course, nickname),
  })),
})

export default (CoursesActions(canvas): *)
