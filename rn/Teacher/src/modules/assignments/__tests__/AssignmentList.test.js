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

/* @flow */

import React from 'react'
import { ActionSheetIOS } from 'react-native'
import { AssignmentList } from '../AssignmentList'
import explore from '../../../../test/helpers/explore'
import timezoneMock from 'timezone-mock'

const template = {
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/helm'),
  ...require('../../../__templates__/grading-periods'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')
jest.mock('TouchableOpacity', () => 'TouchableOpacity')
jest.mock('../../../routing')

jest.mock('ActionSheetIOS', () => ({
  showActionSheetWithOptions: jest.fn(),
}))

let group = template.assignmentGroup()
let gradingPeriod = template.gradingPeriod({ assignmentRefs: [] })
let course = template.course()

let defaultProps = {}

beforeEach(() => {
  timezoneMock.register('US/Pacific')
  jest.resetAllMocks()
  defaultProps = {
    course,
    courseID: course.id,
    assignmentGroups: [group],
    navigator: template.navigator(),
    gradingPeriods: [gradingPeriod],
    refreshAssignmentList: jest.fn(),
    updateCourseDetailsSelectedTabSelectedRow: jest.fn(),
    refresh: jest.fn(),
    refreshing: false,
    courseColor: '#fff',
    selectedRowID: template.assignment().id,
  }
})

afterEach(() => {
  timezoneMock.unregister()
})

test('renders correctly', () => {
  let tree = renderer.create(
    <AssignmentList {...defaultProps} />
  )
  expect(tree.toJSON()).toMatchSnapshot()
  expect(tree.getInstance().props).toMatchObject({
    assignmentGroups: [group],
  })
})

test('renders correctly when pending', () => {
  let tree = renderer.create(
    <AssignmentList {...defaultProps} pending refreshing={false} />
  )
  expect(tree.toJSON()).toMatchSnapshot()
})

test('selected assignment', () => {
  const navigator = template.navigator({
    show: jest.fn(),
  })
  const assignment = group.assignments[0]
  const tree = renderer.create(
    <AssignmentList {...defaultProps} navigator={navigator} />
  )
  const row: any = explore(tree.toJSON()).selectByID(`assignment-list.assignment-list-row.cell-${assignment.id}`)
  row.props.onPress()
  expect(navigator.show).toHaveBeenCalled()
})

test('selected graded discussion', () => {
  const navigator = template.navigator({
    show: jest.fn(),
  })
  const assignment = Object.assign(group.assignments[0], { discussion_topic: { id: '1' } })
  const assignmentGroup = Object.assign(defaultProps.assignmentGroups[0], { assignments: [assignment] })
  const props = {
    ...defaultProps,
    assignmentGroups: [assignmentGroup],
  }
  const tree = renderer.create(
    <AssignmentList {...props} navigator={navigator} />
  )
  const row: any = explore(tree.toJSON()).selectByID(`assignment-list.assignment-list-row.cell-${assignment.id}`)
  row.props.onPress()
  expect(navigator.show).toHaveBeenCalledWith('/courses/987654321/discussion_topics/1')
})

test('selected quiz', () => {
  const navigator = template.navigator({
    show: jest.fn(),
  })
  const assignment = Object.assign(group.assignments[0], { quiz_id: '1' })
  const assignmentGroup = Object.assign(defaultProps.assignmentGroups[0], { assignments: [assignment] })
  const props = {
    ...defaultProps,
    assignmentGroups: [assignmentGroup],
  }
  const tree = renderer.create(
    <AssignmentList {...props} navigator={navigator} />
  )
  const row: any = explore(tree.toJSON()).selectByID(`assignment-list.assignment-list-row.cell-${assignment.id}`)
  row.props.onPress()
  expect(navigator.show).toHaveBeenCalledWith('/courses/987654321/quizzes/1')
})

test('filter button only shows when there are grading periods', () => {
  let tree = renderer.create(
    <AssignmentList {...defaultProps} gradingPeriods={[]} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('filter calls react native action sheet with proper buttons', () => {
  let tree = renderer.create(
    <AssignmentList {...defaultProps} />
  )

  let instance = tree.getInstance()
  let button = explore(tree.toJSON()).selectByID('assignment-list.filter') || {}
  button.props.onPress()

  expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalledWith({
    options: [
      gradingPeriod.title,
      'Cancel',
    ],
    cancelButtonIndex: 1,
    title: 'Filter by:',
  }, instance.updateFilter)
})

test('applyFilter will apply a new filter', () => {
  let groupOne = template.assignmentGroup({
    id: 1,
    assignments: [ template.assignment({ id: 1 }) ],
  })
  let groupTwo = template.assignmentGroup({
    id: 2,
    assignments: [ template.assignment({ id: 2 }) ],
  })
  let gradingPeriod = template.gradingPeriod({
    assignmentRefs: [1],
  })

  let tree = renderer.create(
    <AssignmentList
      {...defaultProps}
      assignmentGroups={[groupOne, groupTwo]}
      gradingPeriods={[gradingPeriod]}
    />
  )
  let instance = tree.getInstance()
  instance.updateFilter(0)

  expect(tree.toJSON()).toMatchSnapshot()
})

test('applyFilter will call refreshlist with the grading period id when it has no assignmentRefs', async () => {
  let tree = renderer.create(
    <AssignmentList
      {...defaultProps}
    />
  )

  let instance = tree.getInstance()
  instance.updateFilter(0)

  expect(defaultProps.refreshAssignmentList).toHaveBeenCalledWith(course.id, gradingPeriod.id)
})

test('applyFilter doesnt apply any filter when the cancel button is pressed', () => {
  let tree = renderer.create(
    <AssignmentList {...defaultProps} />
  )

  let instance = tree.getInstance()
  instance.updateFilter(1)

  expect(tree.toJSON()).toMatchSnapshot()
})

test('selecting clear filter will remove any applied filters', () => {
  let tree = renderer.create(
    <AssignmentList {...defaultProps} />
  )

  let instance = tree.getInstance()
  instance.updateFilter(0)

  let button = explore(tree.toJSON()).selectByID('assignment-list.filter') || {}
  button.props.onPress()

  expect(tree.toJSON()).toMatchSnapshot()
})

test('selects first item on regular horizontal trait collection', () => {
  let tree = renderer.create(
    <AssignmentList {...defaultProps} />
  )

  let instance = tree.getInstance()
  instance.didSelectFirstItem = false
  instance.isRegularScreenDisplayMode = true
  let assignment = instance.data[0].assignments[0]
  instance.selectedAssignment = jest.fn()
  instance.selectFirstListItemIfNecessary()

  expect(instance.selectedAssignment).toHaveBeenCalledWith(assignment)
  expect(instance.didSelectFirstItem).toBe(true)
})

test('does not select first item on empty data', () => {
  let tree = renderer.create(
    <AssignmentList {...defaultProps} />
  )

  let instance = tree.getInstance()
  instance.didSelectFirstItem = false
  instance.isRegularScreenDisplayMode = true
  instance.data = [{ assignments: [] }]
  instance.selectedAssignment = jest.fn()
  instance.selectFirstListItemIfNecessary()

  expect(instance.selectedAssignment).toHaveBeenCalledTimes(0)
  expect(instance.didSelectFirstItem).toBe(false)
})

test('onTraitCollectionChange calls trait collection properties', () => {
  defaultProps.navigator.traitCollection = jest.fn()
  let tree = renderer.create(
    <AssignmentList {...defaultProps} />
  )

  let instance = tree.getInstance()
  instance.onTraitCollectionChange()

  expect(defaultProps.navigator.traitCollection).toHaveBeenCalled()
})

test('traitCollectionDidChange sets display mode to regular', () => {
  let tree = renderer.create(
    <AssignmentList {...defaultProps} />
  )

  let instance = tree.getInstance()
  let traits = { window: { horizontal: 'regular' } }
  instance.traitCollectionDidChange(traits)

  expect(instance.isRegularScreenDisplayMode).toBe(true)
})
