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
import * as templates from '../../../__templates__/index'

jest.mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
jest.mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
jest.mock('../../../routing')

jest.mock('react-native/Libraries/ActionSheetIOS/ActionSheetIOS', () => ({
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
    getGradesForGradingPeriod: jest.fn(),
  }
  jest.clearAllMocks()
})

describe('AssignmentList', () => {
  it('renders pending', () => {
    let tree = shallow(
      <AssignmentList {...defaultProps} pending refreshing={false} />
    )
    expect(tree.find('ActivityIndicatorView').length).toEqual(1)
  })

  it('currentGradingPeriodID is used for initial filter', () => {
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

  it('currentGradingPeriodID can apply when gradingPeriods loads', () => {
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

  it('navigates to assignment', () => {
    const navigator = templates.navigator({
      show: jest.fn(),
    })
    const assignment = group.assignments[0]
    const tree = shallow(new AssignmentList({ ...defaultProps, navigator }).renderRow({ item: assignment, index: 0 }))
    let button = tree.find(`[testID="assignment-list.assignment-list-row.cell-${assignment.id}"]`)
    button.simulate('press')

    expect(navigator.show).toHaveBeenCalled()
  })

  it('navigates to graded discussion', () => {
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

  it('navigates to quiz', () => {
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

  it('hides filter button without grading periods', () => {
    let tree = shallow(
      <AssignmentList {...defaultProps} gradingPeriods={[]} />
    )
    expect(tree.find(`[testID="assignment-list.filter"]`).length).toEqual(0)
  })

  it('shows filter options', () => {
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
    }, expect.any(Function))
  })

  it('filters list by grading period', () => {
    let groupOne = templates.assignmentGroup({
      id: '1',
      assignments: [ templates.assignment({ id: '1', name: 'One' }) ],
    })
    let groupTwo = templates.assignmentGroup({
      id: '2',
      assignments: [ templates.assignment({ id: '2', name: 'Two' }) ],
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
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, fn) => fn(0))
    let filter = tree.find('[testID="assignment-list.filter"]')
    filter.simulate('press')

    let list = tree.find('SectionList')
    let sections = list.props().sections
    let row = shallow(list.props().renderItem({ item: sections[0].data[0], index: 0 })).find('Row')

    expect(tree.find('Heading1').props().children).toEqual(gradingPeriod.title)
    expect(sections.length).toEqual(1)
    expect(row.prop('title')).toEqual('One')

    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, fn) => fn(1))
    filter.simulate('press')
    expect(tree.find('SectionList').props().sections.length).toEqual(2)
  })

  it('will call refreshlist with the grading period id when it has no assignmentRefs', () => {
    let tree = shallow(
      <AssignmentList
        {...defaultProps}
      />
    )
    tree.instance().updateFilter(0)
    expect(defaultProps.refreshAssignmentList).toHaveBeenCalledWith(course.id, gradingPeriod.id, true)
  })

  it('removes filter when clear button pressed', () => {
    let tree = shallow(
      <AssignmentList {...defaultProps} />
    )

    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, fn) => fn(0))
    let filter = tree.find('[testID="assignment-list.filter"]')
    filter.simulate('press')
    let clearButton = tree.find('[testID="assignment-list.filter"]')
    expect(clearButton.props().children).toEqual('Clear filter')
    clearButton.simulate('press')
    tree.update()
    expect(tree.find('Heading1').props().children).toEqual('All')
  })

  it('renders the total grade when provided', () => {
    let tree = shallow(
      <AssignmentList {...defaultProps} currentScore={99} showTotalScore />
    )
    expect(tree.find('[testID="assignment-list.total-grade"] Text').props().children).toEqual('99%')
  })

  it('renders N/A when there is no currentScore', () => {
    let tree = shallow(
      <AssignmentList {...defaultProps} showTotalScore />
    )
    expect(tree.find('[testID="assignment-list.total-grade"] Text').props().children).toEqual('N/A')
  })

  it('shows an activity indicator when the grading period is loading', () => {
    let tree = shallow(
      <AssignmentList {...defaultProps} showTotalScore />
    )
    tree.setState({ loadingGrade: true })
    tree.update()

    expect(tree.find('ActivityIndicator').length).toEqual(1)
  })

  it('refreshes grading period grades on filter and refresh after filter', async () => {
    let grades = templates.enrollment().grades
    defaultProps.getGradesForGradingPeriod = jest.fn(() => Promise.resolve(grades))
    let tree = shallow(
      <AssignmentList {...defaultProps} showTotalScore />
    )
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, fn) => fn(0))
    let filter = tree.find('[testID="assignment-list.filter"]')
    filter.simulate('press')
    tree.find('SectionList').simulate('Refresh')
    await tree.update()
    expect(defaultProps.getGradesForGradingPeriod).toHaveBeenCalledWith(defaultProps.courseID, 'self', gradingPeriod.id)
    expect(defaultProps.getGradesForGradingPeriod).toHaveBeenCalledTimes(2)
    expect(tree.find('[testID="assignment-list.total-grade"] Text').props().children).toEqual(`${grades.current_score}%`)
  })

  it('calls refreshAssignmentList when a filter is updated', () => {
    const tree = shallow(<AssignmentList {...defaultProps} />)
    tree.instance().updateFilter(0)
    expect(defaultProps.refreshAssignmentList).toHaveBeenCalledWith(defaultProps.courseID, gradingPeriod.id, true)
  })

  it('tries to request app store review when closing', () => {
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

  it('donates siri shortcut', () => {
    defaultProps.courseCode = '123'
    defaultProps.courseID = '1'
    shallow(<AssignmentList {...defaultProps} showGrades />)
    expect(NativeModules.SiriShortcutManager.donateSiriShortcut).toHaveBeenCalledWith({
      identifier: 'com.instructure.siri.shortcut.getgrades',
      name: '123',
      url: '/courses/1/grades',
    })
  })
})
