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
