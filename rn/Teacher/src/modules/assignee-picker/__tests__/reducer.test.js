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
