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
}

test('refreshedToDo', () => {
  const grading = template.toDoItem({ type: 'grading' })
  const submitting = template.toDoItem({ type: 'submitting' })
  const items = [grading, submitting]
  const action = refreshedToDo(items)
  expect(reducer({}, action)).toEqual({
    items,
  })
})
