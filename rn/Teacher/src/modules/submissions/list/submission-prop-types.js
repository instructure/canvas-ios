// @flow

import type { EnrollmentsActionProps } from '../../enrollments/enrollments-prop-types'

export type SubmissionStatusProp =
  'none' |
  'missing' |
  'late' |
  'submitted'

export type GradeProp = 'not_submitted' | 'ungraded' | 'excused' | string

export type SubmissionDataProps = {
  userID: string,
  groupID?: string,
  avatarURL?: string,
  name: string,
  status: SubmissionStatusProp,
  grade: ?GradeProp,
  score?: ?number,
  submissionID: ?string,
  submission: ?Object,
}

export type SubmissionProps = SubmissionDataProps & {
  onPress: (userID: string) => void,
}

export type AsyncSubmissionsDataProps = {
  pending: boolean,
  submissions: Array<SubmissionDataProps>,
}

export type SubmissionListDataProps
  = AsyncSubmissionsDataProps
  & {
    groupAssignment: ?{ groupCategoryID: string, gradeIndividually: boolean },
    courseColor: string,
    courseName: string,
    pointsPossible?: string,
    shouldRefresh: boolean,
    anonymous: boolean,
    muted: boolean,
  }

export type SubmissionListActionProps = {
  refreshSubmissions: (courseID: string, assignmentID: string, grouped: boolean) => void,
}

export type GroupSubmissionListActionProps = {
  refreshGroupsForCourse: (courseID: string) => void,
}

export type SubmissionListNavigationParameters = {
  courseID: string,
  assignmentID: string,
  filterType?: string,
}

export type SubmissionListProps
  = SubmissionListDataProps
  & SubmissionListActionProps
  & EnrollmentsActionProps
  & GroupSubmissionListActionProps
  & SubmissionListNavigationParameters
