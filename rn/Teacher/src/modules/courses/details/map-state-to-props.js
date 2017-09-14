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

import CourseActions from '../actions'
import Navigator from '../../../routing/Navigator'

type RoutingParams = {
  +courseID: string,
}

export type CourseDetailsDataProps = {
  +pending: number,
  +error?: ?string,
  +tabs: Array<Tab>,
  +course: Course,
  +color: string,
  +attendanceTabID: ?string,
}

export type CourseDetailsProps = CourseDetailsDataProps
  & typeof CourseActions
  & RoutingParams
  & RefreshProps
  & { navigator: Navigator }

export default function mapStateToProps (state: AppState, { courseID }: RoutingParams): CourseDetailsDataProps {
  let courseState = state.entities.courses[courseID]

  const {
    course,
    color,
  } = courseState

  const pending = state.favoriteCourses.pending +
    courseState.tabs.pending +
    courseState.attendanceTool.pending

  const attendanceTabID = courseState.attendanceTool.tabID

  const availableCourseTabs = ['assignments', 'quizzes', 'discussions', 'announcements', 'people']

  if (global.v12) {
    availableCourseTabs.push(attendanceTabID)
  }

  const tabs = courseState.tabs.tabs
    .filter((tab) => {
      if (tab.id === attendanceTabID && tab.hidden) return false
      return availableCourseTabs.includes(tab.id)
    })
    .sort((t1, t2) => (t1.position - t2.position))
  const error = state.favoriteCourses.error ||
    courseState.tabs.error

  return {
    course,
    color,
    tabs,
    pending,
    error,
    attendanceTabID,
  }
}
