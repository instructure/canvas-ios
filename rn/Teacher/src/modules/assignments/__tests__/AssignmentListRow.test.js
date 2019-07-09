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

import 'react-native'
import React from 'react'
import AssignmentListRow from '../components/AssignmentListRow'

const template = {
  ...require('../../../__templates__/assignments'),
}

const PAST_DATE = new Date(0)
const FUTURE_DATE = new Date(Date.now() + 10000000)

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders correctly', () => {
  let assignment = template.assignment({ due_at: null })
  assignment.needs_grading_count = 0
  let tree = renderer.create(
    <AssignmentListRow assignment={assignment} tintColor='#fff' />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly with needs_grading_count', () => {
  let assignment = template.assignment({ due_at: null })
  assignment.needs_grading_count = 5
  let tree = renderer.create(
    <AssignmentListRow assignment={assignment} tintColor='#fff' />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly with needs_grading_count and set to not_graded', () => {
  let assignment = template.assignment({
    due_at: null,
    needs_grading_count: 5,
    grading_type: 'not_graded',
  })
  let tree = renderer.create(
    <AssignmentListRow assignment={assignment} tintColor='#fff' />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly with closed due dates', () => {
  const one = PAST_DATE.toISOString()
  const two = PAST_DATE.toISOString()
  const three = PAST_DATE.toISOString()
  const assignment = template.assignment({
    lock_at: null,
    all_dates: [template.assignmentDueDate({ lock_at: one }), template.assignmentDueDate({ lock_at: two }), template.assignmentDueDate({ lock_at: three })],
  })

  let tree = renderer.create(
    <AssignmentListRow assignment={assignment} tintColor='#fff' />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly with open due dates', () => {
  const one = FUTURE_DATE.toISOString()
  const two = FUTURE_DATE.toISOString()
  const three = FUTURE_DATE.toISOString()
  const assignment = template.assignment({
    lock_at: null,
    all_dates: [template.assignmentDueDate({ lock_at: one }), template.assignmentDueDate({ lock_at: two }), template.assignmentDueDate({ lock_at: three })],
  })

  let tree = renderer.create(
    <AssignmentListRow assignment={assignment} tintColor='#fff' />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly with selected props', () => {
  let assignment = template.assignment({ due_at: null })
  assignment.needs_grading_count = 0
  let tree = renderer.create(
    <AssignmentListRow assignment={assignment} tintColor='#fff' underlayColor='#eee' selected />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly published icon', () => {
  let assignment = template.assignment({ published: true })
  let tree = renderer.create(
    <AssignmentListRow assignment={assignment}/>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly not published icon', () => {
  let assignment = template.assignment({ published: false })
  let tree = renderer.create(
    <AssignmentListRow assignment={assignment}/>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly assignment icon', () => {
  let assignment = template.assignment({ submission_types: ['on_paper'] })
  let tree = renderer.create(
    <AssignmentListRow assignment={assignment}/>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly quiz icon', () => {
  let assignment = template.assignment({ submission_types: ['online_quiz'] })
  let tree = renderer.create(
    <AssignmentListRow assignment={assignment}/>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly discussion icon', () => {
  let assignment = template.assignment({ submission_types: ['discussion_topic'] })
  let tree = renderer.create(
    <AssignmentListRow assignment={assignment}/>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
