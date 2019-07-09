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

import React from 'react'
import { ActionSheetIOS, NativeModules } from 'react-native'
import { AssignmentList } from '../AssignmentList'
import { shallow } from 'enzyme'
import AssignmentListRow from '../components/AssignmentListRow'
import { getGradesForGradingPeriod } from '../../../canvas-api'
import * as templates from '../../../__templates__/index'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')
jest.mock('TouchableOpacity', () => 'TouchableOpacity')
jest.mock('../../../routing')

jest.mock('ActionSheetIOS', () => ({
  showActionSheetWithOptions: jest.fn(),
}))

let group = templates.assignmentGroup()
let gradingPeriod = {
  ...templates.gradingPeriod(),
  assignmentRefs: [],
}
let course = templates.course()

let defaultProps = {}

beforeEach(() => {
  defaultProps = {
    courseID: course.id,
    courseName: course.name,
    assignmentGroups: [group],
    navigator: templates.navigator(),
    gradingPeriods: [gradingPeriod],
    currentGradingPeriodID: null,
    refreshAssignmentList: jest.fn(),
    updateCourseDetailsSelectedTabSelectedRow: jest.fn(),
    refresh: jest.fn(),
    refreshing: false,
    courseColor: '#fff',
    selectedRowID: templates.assignment().id,
    screenTitle: 'Assignments',
    showTotalScore: false,
    pending: 0,
    ListRow: AssignmentListRow,
  }
  jest.clearAllMocks()
})

test('renders correctly', () => {
  let tree = shallow(
    <AssignmentList {...defaultProps} />
  )
  expect(tree).toMatchSnapshot()
})

test('renders correctly when pending', () => {
  let tree = shallow(
    <AssignmentList {...defaultProps} pending refreshing={false} />
  )
  expect(tree.find('ActivityIndicatorView').length).toEqual(1)
})

test('currentGradingPeriodID is used for initial filter', () => {
  let groupOne = templates.assignmentGroup({
    id: '1',
    assignments: [ templates.assignment({ id: '1' }) ],
  })
  let groupTwo = templates.assignmentGroup({
    id: '2',
    assignments: [ templates.assignment({ id: '2' }) ],
  })
  let gradingPeriod = templates.gradingPeriod({
    assignmentRefs: ['1'],
  })

  let tree = shallow(
    <AssignmentList
      {...defaultProps}
      currentGradingPeriodID={gradingPeriod.id}
      assignmentGroups={[groupOne, groupTwo]}
      gradingPeriods={[gradingPeriod]}
    />
  )

  expect(tree.find('Heading1').props().children).toEqual(gradingPeriod.title)
  expect(tree.find('SectionList').props().sections[0].data).toEqual(groupOne.assignments)
})

test('currentGradingPeriodID can apply when gradingPeriods loads', () => {
  let groupOne = templates.assignmentGroup({
    id: '1',
    assignments: [ templates.assignment({ id: '1' }) ],
  })
  let groupTwo = templates.assignmentGroup({
    id: '2',
    assignments: [ templates.assignment({ id: '2' }) ],
  })
  let gradingPeriod = templates.gradingPeriod({
    assignmentRefs: ['1'],
  })

  let tree = shallow(
    <AssignmentList
      {...defaultProps}
      currentGradingPeriodID={gradingPeriod.id}
      assignmentGroups={[groupOne, groupTwo]}
      gradingPeriods={[]}
    />
  )
  tree.setProps({ gradingPeriods: [gradingPeriod] })
  expect(tree.find('Heading1').props().children).toEqual(gradingPeriod.title)
  expect(tree.find('SectionList').props().sections[0].data).toEqual(groupOne.assignments)
})

test('selected assignment', () => {
  const navigator = templates.navigator({
    show: jest.fn(),
  })
  const assignment = group.assignments[0]
  const tree = shallow(new AssignmentList({ ...defaultProps, navigator }).renderRow({ item: assignment, index: 0 }))
  let button = tree.find(`[testID="assignment-list.assignment-list-row.cell-${assignment.id}"]`)
  button.simulate('press')

  expect(navigator.show).toHaveBeenCalled()
})

test('selected graded discussion', () => {
  const navigator = templates.navigator({
    show: jest.fn(),
  })
  const assignment = Object.assign(group.assignments[0], { discussion_topic: { id: '1' } })
  const assignmentGroup = Object.assign(defaultProps.assignmentGroups[0], { assignments: [assignment] })
  const props = {
    ...defaultProps,
    assignmentGroups: [assignmentGroup],
  }
  const tree = shallow(
    new AssignmentList({ ...props, navigator }).renderRow({ item: assignment, index: 0 })
  )
  let button = tree.find(`[testID="assignment-list.assignment-list-row.cell-${assignment.id}"]`)
  button.simulate('press')
  expect(navigator.show).toHaveBeenCalledWith('/courses/987654321/discussion_topics/1')
})

test('selected quiz', () => {
  const navigator = templates.navigator({
    show: jest.fn(),
  })
  const assignment = Object.assign(group.assignments[0], { quiz_id: '1', discussion_topic: null })
  const assignmentGroup = Object.assign(defaultProps.assignmentGroups[0], { assignments: [assignment] })
  const props = {
    ...defaultProps,
    assignmentGroups: [assignmentGroup],
  }
  const tree = shallow(
    new AssignmentList({ ...props, navigator }).renderRow({ item: assignment, index: 0 })
  )
  let button = tree.find(`[testID="assignment-list.assignment-list-row.cell-${assignment.id}"]`)
  button.simulate('press')
  expect(navigator.show).toHaveBeenCalledWith(assignment.html_url)
})

test('filter button only shows when there are grading periods', () => {
  let tree = shallow(
    <AssignmentList {...defaultProps} gradingPeriods={[]} />
  )
  expect(tree.find(`[testID="assignment-list.filter"]`).length).toEqual(0)
})

test('filter calls react native action sheet with proper buttons', () => {
  let tree = shallow(
    <AssignmentList {...defaultProps} />
  )

  let button = tree.find('[testID="assignment-list.filter"]')
  button.simulate('press')

  expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalledWith({
    options: [
      gradingPeriod.title,
      'Cancel',
    ],
    cancelButtonIndex: 1,
    title: 'Filter by:',
  }, tree.instance().updateFilter)
})

test('applyFilter will apply a new filter', () => {
  let groupOne = templates.assignmentGroup({
    id: '1',
    assignments: [ templates.assignment({ id: '1' }) ],
  })
  let groupTwo = templates.assignmentGroup({
    id: '2',
    assignments: [ templates.assignment({ id: '2' }) ],
  })
  let gradingPeriod = templates.gradingPeriod({
    assignmentRefs: ['1'],
  })

  let tree = shallow(
    <AssignmentList
      {...defaultProps}
      assignmentGroups={[groupOne, groupTwo]}
      gradingPeriods={[gradingPeriod]}
    />
  )
  let instance = tree.instance()
  instance.updateFilter(0)
  tree.update()

  expect(tree.find('Heading1').props().children).toEqual(gradingPeriod.title)
  const sections = tree.find('SectionList').props().sections
  expect(sections.length).toEqual(1)
  expect(sections[0].data).toEqual(groupOne.assignments)
})

test('applyFilter will call refreshlist with the grading period id when it has no assignmentRefs', async () => {
  let tree = shallow(
    <AssignmentList
      {...defaultProps}
    />
  )

  tree.instance().updateFilter(0)

  expect(defaultProps.refreshAssignmentList).toHaveBeenCalledWith(course.id, gradingPeriod.id, true)
})

test('applyFilter doesnt apply any filter when the cancel button is pressed', () => {
  let tree = shallow(
    <AssignmentList {...defaultProps} />
  )

  tree.instance().updateFilter(1)
  tree.update()

  expect(tree.find('Heading1').props().children).toEqual('All Grading Periods')
})

test('selecting clear filter will remove any applied filters', () => {
  let tree = shallow(
    <AssignmentList {...defaultProps} />
  )

  tree.instance().updateFilter(0)
  tree.update()

  let filterButton = tree.find('[testID="assignment-list.filter"]')
  expect(filterButton.props().children).toEqual('Clear filter')
  filterButton.simulate('press')

  tree.update()
  expect(tree.find('Heading1').props().children).toEqual('All Grading Periods')
})

test('selects first item on regular horizontal trait collection', () => {
  let tree = shallow(
    <AssignmentList {...defaultProps} />
  )

  let instance = tree.instance()
  instance.didSelectFirstItem = false
  instance.isRegularScreenDisplayMode = true
  let assignment = instance.data[0].assignments[0]
  instance.selectedAssignment = jest.fn()
  instance.selectFirstListItemIfNecessary()

  expect(instance.selectedAssignment).toHaveBeenCalledWith(assignment)
  expect(instance.didSelectFirstItem).toBe(true)
})

test('does not select first item on regular horizontal trait collection when is modal', () => {
  defaultProps.navigator.isModal = true
  let tree = shallow(
    <AssignmentList {...defaultProps} />
  )

  let instance = tree.instance()
  instance.didSelectFirstItem = false
  instance.isRegularScreenDisplayMode = true
  instance.selectedAssignment = jest.fn()
  instance.selectFirstListItemIfNecessary()

  expect(instance.selectedAssignment).toHaveBeenCalledTimes(0)
  expect(instance.didSelectFirstItem).toBe(false)
})

test('does not select first item on empty data', () => {
  let tree = shallow(
    <AssignmentList {...defaultProps} />
  )

  let instance = tree.instance()
  instance.didSelectFirstItem = false
  instance.isRegularScreenDisplayMode = true
  instance.data = [{ assignments: [] }]
  instance.selectedAssignment = jest.fn()
  instance.selectFirstListItemIfNecessary()

  expect(instance.selectedAssignment).toHaveBeenCalledTimes(0)
  expect(instance.didSelectFirstItem).toBe(false)
})

test('does not select first item when doNotSelectFirstItem is set to  true', () => {
  defaultProps.doNotSelectFirstItem = true
  let tree = shallow(
    <AssignmentList {...defaultProps} />
  )

  let instance = tree.instance()
  instance.didSelectFirstItem = false
  instance.isRegularScreenDisplayMode = true
  instance.selectedAssignment = jest.fn()
  instance.selectFirstListItemIfNecessary()

  expect(instance.selectedAssignment).toHaveBeenCalledTimes(0)
  expect(instance.didSelectFirstItem).toBe(false)
})

test('select first item when doNotSelectFirstItem is not set', () => {
  let tree = shallow(
    <AssignmentList {...defaultProps} />
  )

  let instance = tree.instance()
  instance.didSelectFirstItem = false
  instance.isRegularScreenDisplayMode = true
  instance.selectedAssignment = jest.fn()
  instance.selectFirstListItemIfNecessary()

  expect(instance.selectedAssignment).toHaveBeenCalledTimes(1)
  expect(instance.didSelectFirstItem).toBe(true)
})

test('onTraitCollectionChange calls trait collection properties', () => {
  defaultProps.navigator.traitCollection = jest.fn()
  let tree = shallow(
    <AssignmentList {...defaultProps} />
  )

  tree.instance().onTraitCollectionChange()

  expect(defaultProps.navigator.traitCollection).toHaveBeenCalled()
})

test('traitCollectionDidChange sets display mode to regular', () => {
  let tree = shallow(
    <AssignmentList {...defaultProps} />
  )

  let instance = tree.instance()
  let traits = { window: { horizontal: 'regular' } }
  instance.traitCollectionDidChange(traits)

  expect(instance.isRegularScreenDisplayMode).toBe(true)
})

test('renders the total grade when provided', () => {
  let tree = shallow(
    <AssignmentList {...defaultProps} currentScore={99} showTotalScore />
  )
  expect(tree.find('[testID="assignment-list.total-grade"] Text').props().children).toEqual('99%')
})

test('renders N/A when there is no currentScore', () => {
  let tree = shallow(
    <AssignmentList {...defaultProps} showTotalScore />
  )
  expect(tree.find('[testID="assignment-list.total-grade"] Text').props().children).toEqual('N/A')
})

test('shows an activity indicator when the grading period is loading', () => {
  let tree = shallow(
    <AssignmentList {...defaultProps} showTotalScore />
  )
  tree.setState({ loadingGrade: true })
  tree.update()

  expect(tree.find('ActivityIndicator').length).toEqual(1)
})

test('calls getGradesForGradingPeriod when a filter is updated', async () => {
  let grades = templates.enrollment().grades
  let promise = Promise.resolve(grades)
  getGradesForGradingPeriod.mockReturnValueOnce(promise)

  let tree = shallow(
    <AssignmentList {...defaultProps} showTotalScore />
  )

  tree.instance().updateFilter(0)
  expect(getGradesForGradingPeriod).toHaveBeenCalledWith(defaultProps.courseID, 'self', gradingPeriod.id)

  await promise

  tree.update()
  expect(tree.find('[testID="assignment-list.total-grade"] Text').props().children).toEqual(`${grades.current_score}%`)
})

test('calls refreshAssignmentList when a filter is updated', () => {
  const tree = shallow(<AssignmentList {...defaultProps} />)
  tree.instance().updateFilter(0)
  expect(defaultProps.refreshAssignmentList).toHaveBeenCalledWith(defaultProps.courseID, gradingPeriod.id, true)
})

test('tries to request app store review when closing', () => {
  const tree = shallow(
    <AssignmentList
      {...defaultProps}
      currentScore={89}
      showTotalScore={false}
    />
  )
  tree.unmount()
  expect(NativeModules.AppStoreReview.handleSuccessfulSubmit)
    .not.toHaveBeenCalled()
  tree.setProps({ currentScore: 95 })
  tree.unmount()
  expect(NativeModules.AppStoreReview.handleSuccessfulSubmit)
    .not.toHaveBeenCalled()
  tree.setProps({ showTotalScore: true })
  tree.unmount()
  expect(NativeModules.AppStoreReview.handleSuccessfulSubmit)
    .toHaveBeenCalled()
})

test('calls getGradesForGradingPeriod when refreshed', async () => {
  let grades = templates.enrollment().grades
  let promise = Promise.resolve(grades)
  getGradesForGradingPeriod.mockReturnValue(promise)

  let tree = shallow(
    <AssignmentList {...defaultProps} showTotalScore />
  )

  // Called once when the filter is set
  tree.instance().updateFilter(0)
  expect(getGradesForGradingPeriod).toHaveBeenCalled()

  getGradesForGradingPeriod.mockClear()

  // Called again when we refresh
  tree.find('SectionList').simulate('Refresh')
  expect(getGradesForGradingPeriod).toHaveBeenCalledWith(defaultProps.courseID, 'self', gradingPeriod.id)

  await promise
  await tree.update()
  expect(tree.find('[testID="assignment-list.total-grade"] Text').props().children).toEqual(`${grades.current_score}%`)
})
