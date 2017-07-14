// @flow

import { QuizSubmissionActions } from '../actions'
import { testAsyncAction } from '../../../../../test/helpers/async'
import { apiResponse } from '../../../../../test/helpers/apiMock'

test('should refresh submissions', async () => {
  const response = [{ data: 'hi' }]

  let actions = QuizSubmissionActions({
    getQuizSubmissions: apiResponse(response),
  })

  let result = await testAsyncAction(actions.refreshQuizSubmissions('1', '4'))

  expect(result).toMatchObject([
    {
      type: actions.refreshQuizSubmissions.toString(),
      pending: true,
      payload: {
        quizID: '4',
      },
    },
    {
      type: actions.refreshQuizSubmissions.toString(),
      payload: {
        result: { data: response },
        quizID: '4',
      },
    },
  ])
})

test('refresh includes assignmentID if provided', () => {
  const actions = QuizSubmissionActions({
    getQuizSubmissions: () => {},
  })
  let result = actions.refreshQuizSubmissions('1', '2', '3')
  expect(result).toMatchObject({
    type: actions.refreshQuizSubmissions.toString(),
    payload: {
      quizID: '2',
      assignmentID: '3',
    },
  })
})
