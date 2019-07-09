//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

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

  it('should update selected quiz row', async () => {
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
