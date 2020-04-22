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

import { shallow } from 'enzyme'
import React from 'react'
import { NativeModules } from 'react-native'
import {
  SpeedGrader,
  mapStateToProps,
  refreshSpeedGrader,
  shouldRefresh,
  isRefreshing,
} from '../SpeedGrader'
import shuffle from 'knuth-shuffle-seeded'
import * as modelTemplates from '../../../__templates__'
import DrawerState from '../utils/drawer-state'

jest.mock('../components/GradePicker', () => 'GradePicker')
jest.mock('../components/Header', () => 'Header')
jest.mock('../components/SubmissionPicker', () => 'SubmissionPicker')
jest.mock('../components/FilesTab', () => 'FilesTab')
jest.mock('../components/SimilarityScore', () => 'SimilarityScore')
jest.mock('../../../common/components/BottomDrawer', () => 'BottomDrawer')
jest.mock('knuth-shuffle-seeded', () => jest.fn())

const templates = {
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/helm'),
  ...require('../../submissions/list/__templates__/submission-props'),
  ...modelTemplates,
}

const { NativeAccessibility } = NativeModules

jest.mock('../../submissions/list/get-submissions-props', () => ({
  getSubmissionsProps: () => {
    const templates = {
      ...require('../../submissions/list/__templates__/submission-props'),
    }
    return {
      pending: false,
      submissions: [
        templates.submissionProps({ status: 'missing' }),
        templates.submissionProps(),
      ],
    }
  },
}))

let ownProps = {
  assignmentID: '1',
  userID: '1',
  courseID: '1',
}

let defaultProps = {
  ...ownProps,
  pending: true,
  refreshing: false,
  refresh: jest.fn(),
  refreshSubmissionSummary: jest.fn(),
  navigator: templates.navigator(),
  submissions: [],
  submissionEntities: {},
  resetDrawer: jest.fn(),
  assignmentSubmissionTypes: ['none'],
  gradeSubmissionWithRubric: jest.fn(),
  getCourseEnabledFeatures: jest.fn(),
}

describe('SpeedGrader', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    SpeedGrader.drawerState = new DrawerState()
  })

  it('renders', () => {
    let tree = shallow(
      <SpeedGrader {...defaultProps} />
    )

    expect(tree).toMatchSnapshot()
  })

  it('renders with a filter', () => {
    let props = {
      ...defaultProps,
      submissions: [templates.submissionProps(), templates.submissionProps({ status: 'missing' })],
      filter: subs => subs.filter(sub => sub.status === 'missing'),
      pending: false,
    }
    let tree = shallow(
      <SpeedGrader {...props} />
    )
    let list = tree.find('FlatList')
    expect(list.props().data.length).toEqual(1)
  })

  it('refreshes accessibility after showing loading indicator', () => {
    const props = {
      ...defaultProps,
      pending: true,
    }
    const tree = shallow(<SpeedGrader {...props} />)
    expect(NativeAccessibility.refresh).not.toHaveBeenCalled()
    tree.setProps({
      pending: false,
      submissions: [templates.submissionProps()],
    })
    expect(NativeAccessibility.refresh).toHaveBeenCalled()
  })

  it('doesnt set index until there are some submissions', () => {
    let props = {
      ...defaultProps,
      pending: true,
    }

    let tree = shallow(
      <SpeedGrader {...props} />
    )
    expect(tree.state()).toMatchObject({
      currentPageIndex: undefined,
    })

    tree.setProps({ submissions: [], pending: true })
    expect(tree.state()).toMatchObject({
      currentPageIndex: undefined,
    })

    tree.setProps({ submissions: [templates.submissionProps()], pending: false })
    expect(tree.state()).toMatchObject({
      submissions: [templates.submissionProps()],
      currentPageIndex: 0,
    })
  })

  it('shows the loading spinner when there are no submissions', () => {
    let tree = shallow(
      <SpeedGrader {...defaultProps} />
    )
    expect(tree.find('ActivityIndicator').length).toEqual(1)
  })

  it('shows the loading spinner when pending and not refreshing', () => {
    let tree = shallow(
      <SpeedGrader {...defaultProps} pending={true} />
    )

    expect(tree.find('ActivityIndicator').length).toEqual(1)
  })

  it('renders submissions if there are some', () => {
    const submissions = [templates.submissionProps()]
    const props = { ...defaultProps, submissions, pending: false }
    let tree = shallow(
      <SpeedGrader {...props} />
    )
    let itemTree = shallow(
      tree.instance().renderItem({
        item: {
          key: submissions[0].userID,
          submission: submissions[0],
        },
        index: 0,
      })
    )
    expect(itemTree).toMatchSnapshot()
  })

  it('can toggle scrolling', () => {
    const submissions = [templates.submissionProps()]
    const props = { ...defaultProps, submissions }
    let instance = new SpeedGrader(props)
    instance._flatList = { setNativeProps: jest.fn() }
    let tree = shallow(instance.renderItem({
      item: {
        kehy: submissions[0].userID,
        submission: submissions[0],
      },
      index: 0,
    }))
    let submissionGrader = tree.find('SubmissionGrader')

    submissionGrader.props().setScrollEnabled(false)
    expect(instance._flatList.setNativeProps).toHaveBeenCalledWith({ scrollEnabled: false })

    submissionGrader.props().setScrollEnabled(true)
    expect(instance._flatList.setNativeProps).toHaveBeenCalledWith({ scrollEnabled: true })
  })

  it('supplies getItemLayout', () => {
    let view = shallow(
      <SpeedGrader {...defaultProps} />
    )
    expect(view.instance().getItemLayout(null, 2)).toEqual({
      length: 770,
      offset: 770 * 2,
      index: 2,
    })
  })

  it('refreshes assignment on unmount', () => {
    const refreshAssignment = jest.fn()
    const refreshSubmissions = jest.fn()
    let view = shallow(
      <SpeedGrader
        {...defaultProps}
        refreshAssignment={refreshAssignment}
        refreshSubmissions={refreshSubmissions}
        groupAssignment={{}}
      />
    )
    view.unmount()
    expect(refreshAssignment).toHaveBeenCalledWith(defaultProps.courseID, defaultProps.assignmentID)
    expect(refreshSubmissions).toHaveBeenCalledWith(defaultProps.courseID, defaultProps.assignmentID, true)
  })

  it('defaults current page to 0 without studentIndex', () => {
    const tree = shallow(<SpeedGrader {...defaultProps} studentIndex={null} />)
    expect(tree).toMatchSnapshot()
  })

  it('defaults current page to 0 if userID is not in submissions', () => {
    const tree = shallow(<SpeedGrader {...defaultProps} studentIndex={200} />)
    expect(tree).toMatchSnapshot()
  })

  it('only sets submissions once', () => {
    let submissions = [
      templates.submissionProps(),
      templates.submissionProps(),
    ]
    const tree = shallow(<SpeedGrader {...defaultProps} submissions={submissions} pending={false} />)
    tree.setProps({ submissions: [] })
    expect(tree).toMatchSnapshot()
  })
})

describe('refresh functions', () => {
  beforeEach(() => jest.clearAllMocks())
  const props = {
    courseID: '12',
    assignmentID: '55',
    userID: '145',
    refreshSubmissions: jest.fn(),
    refreshSubmissionSummary: jest.fn(),
    refreshEnrollments: jest.fn(),
    refreshAssignment: jest.fn(),
    refreshGroupsForCourse: jest.fn(),
    resetDrawer: jest.fn(),
    assignmentSubmissionTypes: ['none'],
    submissions: [],
    submissionEntities: {},
    refresh: jest.fn(),
    refreshing: false,
    pending: false,
    navigator: templates.navigator(),
    isModeratedGrading: false,
    hasAssignment: true,
    hasRubric: false,
    groupAssignment: null,
    studentIndex: 1,
    gradeSubmissionWithRubric: jest.fn(),
    getCourseEnabledFeatures: jest.fn(),
  }
  it('refreshSpeedGrader', () => {
    refreshSpeedGrader(props)
    expect(props.refreshEnrollments).toHaveBeenCalledWith(props.courseID)
    expect(props.refreshAssignment).toHaveBeenCalledWith(props.courseID, props.assignmentID)
    expect(props.getCourseEnabledFeatures).toHaveBeenCalledWith(props.courseID)
    expect(props.refreshGroupsForCourse).toHaveBeenCalledWith(props.courseID)
    expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID, true)
  })
  it('isRefreshing', () => {
    const isNot = isRefreshing(props)
    expect(isNot).toBeFalsy()

    const is = isRefreshing({ ...props, pending: true })
    expect(is).toBeTruthy()
  })
  it('shouldRefresh', () => {
    expect(shouldRefresh()).toEqual(true)
  })
})

test('mapStateToProps shuffles when the assignment is an anonymous quiz', () => {
  const quiz = templates.quiz({ anonymous_submissions: true })
  const assignment = templates.assignment({ quiz_id: quiz.id })
  const appState = templates.appState({
    entities: {
      submissions: {},
      assignments: {
        [assignment.id]: {
          data: assignment,
        },
      },
      quizzes: {
        [quiz.id]: {
          data: quiz,
        },
      },
      courses: {},
    },
  })
  mapStateToProps(appState, {
    assignmentID: assignment.id,
    courseID: '2',
    userID: '3',
    studentIndex: 1,
  })
  expect(shuffle).toHaveBeenCalled()
})

test('mapStateToProps shuffles when the assignment has anonymize_students turned on', () => {
  const assignment = templates.assignment({ anonymize_students: true })
  const appState = templates.appState({
    entities: {
      submissions: {},
      assignments: {
        [assignment.id]: {
          data: assignment,
        },
      },
      courses: {
        '2': {},
      },
    },
  })
  mapStateToProps(appState, {
    assignmentID: assignment.id,
    courseID: '2',
    userID: '3',
    studentIndex: 1,
  })
  expect(shuffle).toHaveBeenCalled()
})

test('mapStateToProps sets groupAssignment when there is a group_category_id', () => {
  const assignment = templates.assignment({
    group_category_id: '1',
    grade_group_students_individually: false,
  })
  const appState = templates.appState({
    entities: {
      submissions: {},
      assignments: {
        [assignment.id]: {
          data: assignment,
        },
      },
      courses: {
        '2': {
          groups: {
            refs: ['1'],
          },
        },
      },
      groups: {
        '1': {
          group: templates.group({ group_category_id: '1' }),
        },
      },
    },
  })
  let newState = mapStateToProps(appState, {
    assignmentID: assignment.id,
    courseID: '2',
    userID: '3',
    studentIndex: 1,
  })
  expect(newState.groupAssignment).toEqual({
    groupCategoryID: '1',
    gradeIndividually: false,
  })
})
