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

import { getSubmissionsProps } from './get-submissions-props'
import shuffle from 'knuth-shuffle-seeded'
import { isAssignmentAnonymous } from '../../../common/anonymous-grading'

type RoutingProps = {
  courseID: string,
  assignmentID: string,
}

export function mapStateToProps (state: AppState, { courseID, assignmentID }: RoutingProps) {
  const { entities } = state
  // submissions
  const assignmentContent = entities.assignments[assignmentID]
  const courseContent = entities.courses[courseID]
  let pointsPossible
  let isMissingGroupsData = false
  let isGroupGradedAssignment = false
  if (assignmentContent && assignmentContent.data) {
    const a = assignmentContent.data
    isMissingGroupsData = (!a.grade_group_students_individually && a.group_category_id > 0 && !Object.keys(entities.groups).length)
    isGroupGradedAssignment = a.group_category_id != null && !a.grade_group_students_individually
    pointsPossible = assignmentContent.data.points_possible
  }

  let submissions = getSubmissionsProps(entities, courseID, assignmentID)

  let courseColor = '#FFFFFF'
  if (courseContent && courseContent.color) {
    courseColor = courseContent.color
  }

  let courseName = ''
  if (courseContent && courseContent.course) {
    courseName = courseContent.course.name
  }

  let anonymous = isAssignmentAnonymous(state, courseID, assignmentID)

  let assignmentName = ''
  let gradingType = 'points'
  if (assignmentContent && assignmentContent.data) {
    assignmentName = assignmentContent.data.name
    gradingType = assignmentContent.data.grading_type
  }

  const sections = Object.values(entities.sections).filter((s: any) => {
    return s.course_id === courseID
  })

  return {
    isMissingGroupsData,
    isGroupGradedAssignment,
    courseColor,
    courseName,
    pointsPossible,
    pending: submissions.pending,
    submissions: anonymous ? shuffle(submissions.submissions.slice(), assignmentID) : submissions.submissions,
    anonymous,
    assignmentName,
    gradingType,
    sections,
  }
}
