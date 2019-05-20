//
// Copyright (C) 2017-present Instructure, Inc.
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

import showColorOverlayForCourse from '../../../common/show-color-overlay-for-course'

export type StateProps = {
  course: Course,
  color: string,
  pending: number,
  error: ?string,
  showColorOverlay: boolean,
}

export default function stateToProps (state: AppState, ownProps: {courseID: string}): StateProps {
  let course: CourseState = state.entities.courses[ownProps.courseID]
  return {
    course: course.course,
    color: course.color,
    pending: state.favoriteCourses.pending + course.pending,
    error: course.error,
    showColorOverlay: showColorOverlayForCourse(course.course, state.userInfo.userSettings.hide_dashcard_color_overlays),
  }
}
