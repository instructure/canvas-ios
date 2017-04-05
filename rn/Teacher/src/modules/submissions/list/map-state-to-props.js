// @flow

import type {
  SubmissionStatusProp,
  SubmissionProp,
  SubmissionListDataProps,
  GradeProp,
} from './submission-prop-types'

const rand = () => (Math.floor(Math.random() * 20 + 130))

const sub = (userID: string, name: string, status: SubmissionStatusProp, grade: ?GradeProp): SubmissionProp => {
  const avatarURL = `https://fillmurray.com/${rand()}/${rand()})}`
  return {
    onPress: () => { console.log('tapped submission', userID) },
    userID,
    avatarURL,
    name,
    status,
    grade,
  }
}

export function mapStateToProps (state: AppState): SubmissionListDataProps {
  const pending = 0
  const course = { color: '#0080FF' }
  const submissions: Array<SubmissionProp> = [
    sub('1', 'Allen Thomas', 'late', '72.3%'),
    sub('2', 'Belinda Herrington', 'submitted', 'A-'),
    sub('3', 'Charlie Rose', 'submitted', 'ungraded'),
    sub('4', 'Danielle Agrios', 'none', null),
    sub('5', 'Epaphras Allensworth', 'late', '91.5%'),
    sub('6', 'Farriday Johnston', 'missing', null),
    sub('7', 'Genni Fuller', 'submitted', 'ungraded'),
  ]
  return {
    course,
    submissions,
    pending,
  }
}
