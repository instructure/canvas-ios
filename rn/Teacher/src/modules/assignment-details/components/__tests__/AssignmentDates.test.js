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

/**
 * @flow
 */

import 'react-native'
import React from 'react'
import AssignmentDates from '../AssignmentDates'
import renderer from 'react-test-renderer'

const template = {
  ...require('../../../../__templates__/assignments'),
}

test('render with multiple due dates', () => {
  const assignment = template.assignment({
    due_at: undefined,
    all_dates: [template.assignmentDueDate({ base: true }), template.assignmentDueDate({ base: false })],
  })
  let tree = renderer.create(
    <AssignmentDates assignment={assignment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render with multiple due dates', () => {
  const assignment = template.assignment({
    lock_at: (new Date(0).toISOString()),
  })
  let tree = renderer.create(
    <AssignmentDates assignment={assignment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
