// @flow

import type {
  SubmissionListDataProps,
} from './submission-prop-types'
import { getSubmissionsProps } from './get-submissions-props'

type RoutingProps = {
  courseID: string,
  assignmentID: string,
}

function getEnrollments (courseContent?: CourseContentState, enrollments: EnrollmentsState): Array<Enrollment> {
  if (!courseContent) { return [] }
  return courseContent.enrollments.refs
    .map(ref => enrollments[ref])
}

export function mapStateToProps ({ entities }: AppState, { courseID, assignmentID }: RoutingProps): SubmissionListDataProps {
  // enrollments
  const courseContent = entities.courses[courseID]
  const enrollments = getEnrollments(courseContent, entities.enrollments)

  // submissions
  const assignmentContent = entities.assignments[assignmentID]
  let submissionCount = 0
  if (assignmentContent && assignmentContent.submissions && assignmentContent.submissions.refs) {
    submissionCount = assignmentContent.submissions.refs.length
  }

  const submissions = getSubmissionsProps(entities, courseID, assignmentID)
  const courseColor = courseContent.color || '#FFFFFF'
  const shouldRefresh = enrollments.length === 0 || submissionCount === 0

  return {
    courseColor,
    shouldRefresh,
    ...submissions,
  }
}
