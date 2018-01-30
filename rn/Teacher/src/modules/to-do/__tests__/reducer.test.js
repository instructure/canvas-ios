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

// @flow

import reducer from '../reducer'
import { default as ListActions } from '../list/actions'

const { refreshedToDo } = ListActions

const template = {
  ...require('../../../__templates__/toDo'),
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/quiz'),
}

describe('refreshedToDo', () => {
  it('stores grading items', () => {
    const assignment = template.toDoItem({
      type: 'grading',
      assignment: template.assignment({
        course_id: '1',
        id: '2',
      }),
    })
    const quiz = template.toDoItem({
      type: 'grading',
      assignment: null,
      quiz: template.quiz({
        course_id: '1',
        id: '2',
      }),
    })
    const submitting = template.toDoItem({ type: 'submitting' })
    const items = [assignment, quiz, submitting]
    const action = refreshedToDo(items)
    expect(reducer({}, action)).toEqual({
      needsGrading: {
        '1-assignment-2': assignment,
        '1-quiz-2': quiz,
      },
    })
  })

  it('removes all if items empty', () => {
    const initialState = {
      needsGrading: [template.toDoItem({ type: 'grading' })],
    }
    const action = refreshedToDo([])
    expect(reducer(initialState, action)).toEqual({
      needsGrading: [],
    })
  })
})
