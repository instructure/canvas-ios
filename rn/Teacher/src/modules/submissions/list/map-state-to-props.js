// @flow

import type {
  SubmissionListDataProps,
} from './submission-prop-types'
import { getSubmissionsProps } from './get-submissions-props'
import shuffle from 'knuth-shuffle-seeded'
import {
  getGroupSubmissionProps,
} from '../../groups/submissions/get-group-submission-props'

type RoutingProps = {
  courseID: string,
  assignmentID: string,
}

export function mapStateToProps ({ entities }: AppState, { courseID, assignmentID }: RoutingProps): SubmissionListDataProps {
  // submissions
  const assignmentContent = entities.assignments[assignmentID]
  let pointsPossible
  let groupAssignment = null
  if (assignmentContent && assignmentContent.data) {
    const a = assignmentContent.data
    if (a.group_category_id) {
      groupAssignment = {
        groupCategoryID: a.group_category_id,
        gradeIndividually: a.grade_group_students_individually,
      }
    }
    pointsPossible = assignmentContent.data.points_possible
  }

  let submissions
  if (groupAssignment != null && !groupAssignment.gradeIndividually) {
    submissions = getGroupSubmissionProps(entities, courseID, assignmentID)
  } else {
    submissions = getSubmissionsProps(entities, courseID, assignmentID)
  }

  const courseContent = entities.courses[courseID]
  let courseColor = '#FFFFFF'
  if (courseContent && courseContent.color) {
    courseColor = courseContent.color
  }

  let courseName = ''
  if (courseContent && courseContent.course) {
    courseName = courseContent.course.name
  }

  let anonymous = !!assignmentContent && assignmentContent.anonymousGradingOn
  let muted = !!assignmentContent && assignmentContent.data.muted

  let assignmentName = ''
  if (assignmentContent && assignmentContent.data) {
    assignmentName = assignmentContent.data.name
  }
  let course = null
  if (courseContent && courseContent.course) {
    course = courseContent.course
  }

  return {
    groupAssignment,
    courseColor,
    courseName,
    pointsPossible,
    pending: submissions.pending,
    submissions: anonymous ? shuffle(submissions.submissions.slice(), assignmentID) : submissions.submissions,
    anonymous,
    muted,
    assignmentName,
    course,
  }
}
