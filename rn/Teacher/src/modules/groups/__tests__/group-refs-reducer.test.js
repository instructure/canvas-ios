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

import groups from '../group-refs-reducer'
import Actions from '../actions'

const { refreshGroupsForCourse } = Actions

const templates = {
  ...require('../../../__templates__/group'),
}

test('it captures group ids', () => {
  const data = [
    templates.group({ id: '1' }),
    templates.group({ id: '2' }),
  ]

  const pending = {
    type: refreshGroupsForCourse.toString(),
    pending: true,
  }
  const resolved = {
    type: refreshGroupsForCourse.toString(),
    payload: { result: { data } },
  }

  const pendingState = groups(undefined, pending)
  expect(pendingState).toEqual({ refs: [], pending: 1 })
  expect(groups(pendingState, resolved)).toEqual({
    pending: 0,
    refs: ['1', '2'],
  })
})
