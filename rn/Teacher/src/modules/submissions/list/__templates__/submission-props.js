// @flow

import template, { type Template } from '../../../../utils/template'
import type { SubmissionDataProps } from '../submission-prop-types'

export const submissionProps: Template<SubmissionDataProps> = template({
  grade: 'not_submitted',
  name: 'Jonny Ive',
  status: 'none',
  userID: '9',
  avatarURL: 'http://www.fillmurray.com/100/100',
})
