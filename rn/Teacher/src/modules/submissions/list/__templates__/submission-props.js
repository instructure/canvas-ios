// @flow

import template, { type Template } from '../../../../utils/template'
import type { SubmissionDataProps } from '../submission-prop-types'

const templates = {
  ...require('../../../../__templates__/submissions'),
}

const submissionWithHistory = templates.submissionHistory()

export const submissionProps: Template<SubmissionDataProps> = template({
  grade: 'B-',
  name: submissionWithHistory.user.name,
  status: 'submitted',
  userID: submissionWithHistory.user.id,
  avatarURL: submissionWithHistory.user.avatar_url,
})
