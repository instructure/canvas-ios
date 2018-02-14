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

/* eslint-disable flowtype/require-valid-file-annotation */

import Navigator from '../../routing/Navigator'

export type AssignmentDetailsState = {
  +assignmentDetails: Assignment,
  +courseColor: string,
  +pending: number,
  +error?: ?string,
}

export type AssignmentDetailsProps = {
  assignmentDetails: Assignment,
  navigator: Navigator,
  course: Course,
  courseID: string,
  courseColor?: string,
  courseName?: string,
  assignmentID: string,
  error?: any,
  pending?: number,
  updateAssignment: Function,
  refreshAssignmentDetails: (courseID: string, assignmentID: string, getSubmissionStatus?: boolean) => Promise<Assignment>,
  refreshAssignmentList: (courseID: string) => Promise<Assignment>,
  refreshCourses: () => void,
  cancelAssignmentUpdate: (originalAssignment: Assignment) => void,
  getSessionlessLaunchURL: Function,
  showSubmissionSummary: boolean,
} & RefreshProps

export function mapStateToProps (state: AppState, ownProps: AssignmentDetailsProps): AssignmentDetailsState {
  const assignmentEntity = state.entities.assignments[ownProps.assignmentID]
  let assignment = assignmentEntity && assignmentEntity.data

  const courseEntity = state.entities.courses[ownProps.courseID]
  let course = courseEntity && courseEntity.course
  let courseName = course ? course.name : ''

  let enrollment = course && course.enrollments && course.enrollments[0]
  let pending = course && course.assignmentGroups ? course.assignmentGroups.pending : 0

  return {
    assignmentDetails: assignment,
    course: course,
    courseColor: courseEntity && courseEntity.color,
    courseName,
    pending,
    showSubmissionSummary: enrollment && enrollment.type !== 'designer' || false,
  }
}

export function updateMapStateToProps (state: AppState, ownProps: AssignmentDetailsProps): AssignmentDetailsState {
  const assignment = state.entities.assignments[ownProps.assignmentID].data
  const course = state.entities.courses[ownProps.courseID]

  return {
    assignmentDetails: assignment,
    courseColor: course.color,
    pending: state.entities.assignments[ownProps.assignmentID].pending,
    error: state.entities.assignments[ownProps.assignmentID].error,
  }
}
