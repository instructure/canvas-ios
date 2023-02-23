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

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import 'react-native'
import React from 'react'
import { AssignmentDueDates } from '../AssignmentDueDates'
import renderer from 'react-test-renderer'

jest
  .mock('../../../routing')
  .mock('../../../routing/Screen')

const template = {
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/users'),
  ...require('../../../__templates__/helm'),
}

test('renders', () => {
  const props = {
    assignment: template.assignment(),
    navigator: template.navigator(),
    refreshAssignment: jest.fn(),
  }

  let tree = renderer.create(
    <AssignmentDueDates {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders with overrides', () => {
  const id = '123456'
  const date = template.assignmentDueDate({ id })
  const override = template.assignmentOverride({ id })
  const props = {
    assignment: template.assignment({
      all_dates: [date],
      overrides: [override],
    }),
    navigator: template.navigator(),
    refreshAssignment: jest.fn(),
  }

  let tree = renderer.create(
    <AssignmentDueDates {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders with overrides and specific student ids and sections', () => {
  const user1 = template.user({ id: '1', name: 'Alice' })
  const user2 = template.user({ id: '2', name: 'Bob', pronouns: 'He/Him' })
  const studentId = '123456'
  const studentDate = template.assignmentDueDate({ id: studentId })
  const studentOverride = template.assignmentOverride({ id: studentId, student_ids: [user1.id, user2.id] })
  const sectionId = '9999999999'
  const sectionDate = template.assignmentDueDate({ id: sectionId, title: 'Section 1' })
  const sectionOverride = template.assignmentOverride({ id: sectionId })
  const messyDataOne = template.assignmentDueDate()
  const messyDataTwo = template.assignmentDueDate({ title: 'messy', id: 'invalid', unlock_at: null, lock_at: null, due_at: null })
  const assignment = template.assignment({
    all_dates: [studentDate, sectionDate, messyDataOne, messyDataTwo],
    overrides: [studentOverride, sectionOverride],
  })

  const refreshUsers = jest.fn()
  const props = {
    refreshUsers,
    assignment,
    assignmentID: assignment.id,
    users: {
      [user1.id]: user1,
      [user2.id]: user2,
    },
    navigator: template.navigator(),
    refreshAssignment: jest.fn(),
  }

  let tree = shallow(<AssignmentDueDates {...props} />)
  expect(tree.find('[testID="123456"]').find(`[children="Alice, Bob (He/Him)"]`).exists()).toBe(true)
  expect(tree.find('[testID="123456"]').find(`[children="Due May 31, 2037 at 11:59 PM"]`).exists()).toBe(true)
  expect(refreshUsers).toBeCalled()
})

test('null assignment', () => {
  const props = {
    courseID: '1',
    assignmentID: '1',
    quizID: '2',
    assignment: undefined,
    navigator: template.navigator({ show: jest.fn() }),
    refreshAssignment: jest.fn(),
  }
  let tree = shallow(<AssignmentDueDates {...props} />)
  expect(tree.find('ActivityIndicatorView').exists()).toBe(true)
})
