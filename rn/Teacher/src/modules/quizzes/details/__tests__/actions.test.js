/* @flow */

import { Actions } from '../actions'
import { apiResponse } from '../../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../../test/helpers/async'

const template = {
  ...require('../../../../api/canvas-api/__templates__/quiz'),
}

describe('refreshQuiz', () => {
  it('should refresh quiz', async () => {
    const quiz = template.quiz({ title: 'refreshed' })
    const api = {
      getQuiz: apiResponse(quiz),
    }
    const actions = Actions(api)
    const action = actions.refreshQuiz('21', '11509')
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.refreshQuiz.toString(),
        pending: true,
      },
      {
        type: actions.refreshQuiz.toString(),
        payload: {
          result: { data: quiz },
          courseID: '21',
          quizID: '11509',
        },
      },
    ])
  })
})
