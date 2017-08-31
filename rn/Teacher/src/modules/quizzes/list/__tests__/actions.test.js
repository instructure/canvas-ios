/* @flow */

import { Actions } from '../actions'
import { apiResponse } from '../../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../../test/helpers/async'
import { UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION } from '../../../courses/actions'

const template = {
  ...require('../../../../__templates__/quiz'),
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

  it('should update selected quiz row', async() => {
    const rowID = '1'
    const actions = Actions()
    const result = actions.updateCourseDetailsSelectedTabSelectedRow(rowID)

    expect(result).toMatchObject({
      type: UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION,
      payload: {
        rowID: rowID,
      },
    })
  })
})
