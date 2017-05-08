/* @flow */

import { Actions } from '../actions'
import { apiResponse } from '../../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../../test/helpers/async'

const template = {
  ...require('../../../../api/canvas-api/__templates__/quiz'),
}

describe('refreshQuizzes', () => {
  it('should get quizzes', async () => {
    const quiz = template.quiz({ title: 'refreshed' })
    const api = {
      getQuizzes: apiResponse([quiz]),
    }
    const actions = Actions(api)
    const action = actions.refreshQuizzes('35')
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.refreshQuizzes.toString(),
        pending: true,
      },
      {
        type: actions.refreshQuizzes.toString(),
        payload: {
          result: { data: [quiz] },
          courseID: '35',
        },
      },
    ])
  })
})
