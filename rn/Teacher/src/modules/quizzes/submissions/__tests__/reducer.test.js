// @flow

import Actions from '../actions'
import { quizSubmissions, quizAssignmentSubmissions } from '../reducer'

const { refreshQuizSubmissions } = Actions
const template = {
  ...require('../../../../api/canvas-api/__templates__/quizSubmission'),
  ...require('../../../../api/canvas-api/__templates__/submissions'),
}
describe('QuizSubmissionList reducer', () => {
  test('it captures entities for quiz submissions', () => {
    const qs1 = template.quizSubmission({ id: '1' })
    const qs2 = template.quizSubmission({ id: '2' })

    let data = {
      quiz_submissions: [
        qs1,
        qs2,
      ],
    }

    const action = {
      type: refreshQuizSubmissions.toString(),
      payload: { result: { data } },
    }

    expect(quizSubmissions({}, action)).toEqual({
      [qs1.id]: {
        data: qs1,
        pending: 0,
        error: null,
      },
      [qs2.id]: {
        data: qs2,
        pending: 0,
        error: null,
      },
    })
  })

  test('it captures entities for quiz submissions', () => {
    const s1 = template.submission({ id: '1' })

    let data = {
      submissions: [s1],
    }

    const action = {
      type: refreshQuizSubmissions.toString(),
      payload: { result: { data } },
    }

    expect(quizAssignmentSubmissions({}, action)).toEqual({
      [s1.id]: {
        submission: s1,
        pending: 0,
        error: null,
      },
    })
  })
})
