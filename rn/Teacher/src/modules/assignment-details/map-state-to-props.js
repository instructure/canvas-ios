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

/* eslint-disable flowtype/require-valid-file-annotation */

import Navigator from '../../routing/Navigator'
import { isTeacher } from '../app'

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

  let showSubmissionSummary = false
  if (isTeacher() && enrollment) {
    showSubmissionSummary = enrollment.type !== 'designer'
  }

  return {
    assignmentDetails: assignment,
    course: course,
    courseColor: courseEntity && courseEntity.color,
    courseName,
    pending,
    showSubmissionSummary,
  }
}

export function updateMapStateToProps (state: AppState, ownProps: AssignmentDetailsProps): AssignmentDetailsState {
  const assignment = state.entities.assignments[ownProps.assignmentID].data
  const course = state.entities.courses[ownProps.courseID]

  return {
    assignmentDetails: assignment,
    courseColor: course.color,
    pending: state.entities.assignments[ownProps.assignmentID]?.pending,
    error: state.entities.assignments[ownProps.assignmentID]?.error,
  }
}
