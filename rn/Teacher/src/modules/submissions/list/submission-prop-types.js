// @flow

export type SubmissionStatusProp =
  'none' |
  'missing' |
  'late' |
  'submitted'

export type GradeProp = 'ungraded' | string

export type SubmissionProp = {
  +userID: string,
  +avatarURL: string,
  +name: string,
  +status: SubmissionStatusProp,
  +grade: ?GradeProp,
  +onPress: (userID: string) => void,
}

export type SubmissionListDataProps = AsyncState & {
  +course: { color: string },
  +submissions: Array<SubmissionProp>,
}

export type SubmissionListActionProps = {
  +refreshSubmissions: (courseID: string, assignmentID: string) => Promise<*>,
}

// TODO: add actions
export type SubmissionListProps = SubmissionListDataProps
