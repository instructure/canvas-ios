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
