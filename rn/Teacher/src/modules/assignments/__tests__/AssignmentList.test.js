/* @flow */

import React from 'react'
import { ActionSheetIOS } from 'react-native'
import { AssignmentList } from '../AssignmentList'
import explore from '../../../../test/helpers/explore'
import timezoneMock from 'timezone-mock'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/react-native-navigation'),
  ...require('../../../api/canvas-api/__templates__/grading-periods'),
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

let defaultProps = {
  course,
  courseID: course.id,
  assignmentGroups: [group],
  navigator: template.navigator(),
  gradingPeriods: [gradingPeriod],
  refreshAssignmentList: jest.fn(),
}

beforeEach(() => {
  timezoneMock.register('US/Pacific')
  jest.resetAllMocks()
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

test('selected assignment', () => {
  const navigator = template.navigator({
    push: jest.fn(),
  })
  const assignment = group.assignments[0]
  const tree = renderer.create(
    <AssignmentList {...defaultProps} navigator={navigator} />
  )
  const row: any = explore(tree.toJSON()).selectByID(`assignment-${assignment.id}`)
  row.props.onPress()
  expect(navigator.push).toHaveBeenCalled()
})

test('getSectionHeaderData', () => {
  let tree = renderer.create(
    <AssignmentList {...defaultProps} />
  )

  const data = {
    key: 'data',
  }
  const sectionHeaderData = tree.getInstance().getSectionHeaderData(data, 'key')
  expect(sectionHeaderData).toEqual('data')
})

test('getRowData', () => {
  let tree = renderer.create(
    <AssignmentList {...defaultProps} />
  )

  const data = {
    'courseID:assignmentID': 'data',
  }
  const sectionHeaderData = tree.getInstance().getRowData(data, 'courseID', 'assignmentID')
  expect(sectionHeaderData).toEqual('data')
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

test('applyFilter will call refreshlist with the grading period id when it has no assignmentRefs', () => {
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
