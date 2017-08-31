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

import {
  sections,
} from '../reducer'
import Actions from '../actions'

const { refreshSections } = Actions
const templates = {
  ...require('../../../__templates__/section'),
}

test('captures entities mapped by id', () => {
  const data = [
    templates.section({ id: '3' }),
    templates.section({ id: '5' }),
  ]

  const action = {
    type: refreshSections.toString(),
    payload: {
      result: {
        data,
      },
    },
  }

  expect(sections({}, action)).toEqual({
    '3': data[0],
    '5': data[1],
  })
})
