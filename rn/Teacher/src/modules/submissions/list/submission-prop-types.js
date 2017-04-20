// @flow

import type { EnrollmentsActionProps } from '../../enrollments/enrollments-prop-types'

export type SubmissionStatusProp =
  'none' |
  'missing' |
  'late' |
  'submitted'

export type GradeProp = 'not_submitted' | 'ungraded' | 'excused' | string

export type SubmissionDataProps = {
  +userID: string,
  +avatarURL: string,
  +name: string,
  +status: SubmissionStatusProp,
  +grade: ?GradeProp,
}

export type SubmissionProps = SubmissionDataProps & {
  +onPress: (userID: string) => void,
}

export type SubmissionListDataProps = {
  +pending: boolean,
  +courseColor: string,
  +submissions: Array<SubmissionDataProps>,
  +shouldRefresh: boolean,
}

export type SubmissionListActionProps = {
  +refreshSubmissions: (courseID: string, assignmentID: string) => void,
}

export type SubmissionListNavigationParameters = {
  +courseID: string,
  +assignmentID: string,
}

export type SubmissionListProps
  = SubmissionListDataProps
  & SubmissionListActionProps
  & EnrollmentsActionProps
  & SubmissionListNavigationParameters
