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
  enrollments,
} from '../enrollments-refs-reducer'
import Actions from '../actions'

const { refreshEnrollments } = Actions
const templates = {
  ...require('../../../__templates__/enrollments'),
}

const defaultRefs = { pending: 0, refs: [] }

test('captures the enrollment ids', () => {
  const data = [
    templates.enrollment({ id: '4' }),
    templates.enrollment({ id: '6' }),
  ]

  const pending = {
    type: refreshEnrollments.toString(),
    pending: true,
  }

  const resolved = {
    type: refreshEnrollments.toString(),
    payload: { result: { data } },
  }

  const pendingState = enrollments(defaultRefs, pending)
  expect(pendingState).toEqual({
    refs: [],
    pending: 1,
  })

  expect(enrollments(pendingState, resolved)).toEqual({
    refs: ['4', '6'],
    pending: 0,
  })
})
