//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

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
