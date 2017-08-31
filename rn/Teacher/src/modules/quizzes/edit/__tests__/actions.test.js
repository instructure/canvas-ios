/* @flow */

import { Actions } from '../actions'
import { apiResponse } from '../../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../../test/helpers/async'

const template = {
  ...require('../../../../__templates__/quiz'),
}

describe('updateQuiz', () => {
  it('should update quiz', async () => {
    const original = template.quiz({ title: 'original' })
    const updated = template.quiz({ title: 'updated' })
    const api = {
      updateQuiz: apiResponse(updated),
    }
    const actions = Actions(api)
    const action = actions.updateQuiz(updated, '21234', original)
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.updateQuiz.toString(),
        pending: true,
        payload: {
          originalQuiz: original,
          updatedQuiz: updated,
        },
      },
      {
        type: actions.updateQuiz.toString(),
        payload: {
          result: { data: updated },
          originalQuiz: original,
          updatedQuiz: updated,
        },
      },
    ])
  })
})
