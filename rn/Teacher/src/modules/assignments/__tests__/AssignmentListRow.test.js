/* @flow */

import 'react-native'
import React from 'react'
import AssignmentListRow from '../components/AssignmentListRow'
import moment from 'moment'

const template = {
  ...require('../../../__templates__/assignments'),
}

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

test('renders correctly with closed due dates', () => {
  const one = moment().subtract(1, 'day').format()
  const two = moment().subtract(2, 'day').format()
  const three = moment().subtract(3, 'day').format()
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
  const one = moment().add(1, 'day').format()
  const two = moment().add(2, 'day').format()
  const three = moment().add(3, 'day').format()
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
    <AssignmentListRow assignment={assignment} tintColor='#fff' underlayColor='#eee' selectedColor='#f00'/>
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
