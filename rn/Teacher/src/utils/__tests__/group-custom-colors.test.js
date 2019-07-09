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

import groupCustomColors from '../group-custom-colors'

test('group context codes by type', () => {
  const colors = {
    custom_colors: {
      course_1: '#fff',
      course_2: '#eee',
      account_1: '#ddd',
      group_2: '#aaa',
    },
  }

  expect(groupCustomColors(colors)).toEqual({
    custom_colors: {
      course: {
        '1': '#fff',
        '2': '#eee',
      },
      account: {
        '1': '#ddd',
      },
      group: {
        '2': '#aaa',
      },
    },
  })
})
