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

jest.mock('../components/GradePicker')
jest.mock('../components/Header')
jest.mock('../components/SubmissionPicker.js')
jest.mock('../components/FilesTab')
jest.mock('../components/SimilarityScore')
jest.mock('../../../common/components/BottomDrawer')
jest.mock('knuth-shuffle-seeded', () => jest.fn())

const { NativeAccessibility } = NativeModules

const templates = {
  ...require('../../../__templates__/submissions'),
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/quiz'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/helm'),
  ...require('../../submissions/list/__templates__/submission-props'),
}

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
  refreshSubmissions: jest.fn(),
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
      tree.instance().renderItem({ item: {
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
    instance.scrollView = { setNativeProps: jest.fn() }
    let tree = shallow(instance.renderItem({
      item: {
        kehy: submissions[0].userID,
        submission: submissions[0],
      },
      index: 0,
    }))
    let submissionGrader = tree.find('SubmissionGrader')

    submissionGrader.props().setScrollEnabled(false)
    expect(instance.scrollView.setNativeProps).toHaveBeenCalledWith({ scrollEnabled: false })

    submissionGrader.props().setScrollEnabled(true)
    expect(instance.scrollView.setNativeProps).toHaveBeenCalledWith({ scrollEnabled: true })
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
    const spy = jest.fn()
    let view = shallow(
      <SpeedGrader {...defaultProps} refreshAssignment={spy} />
    )
    view.unmount()
    expect(spy).toHaveBeenCalledWith(defaultProps.courseID, defaultProps.assignmentID)
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
  beforeEach(() => jest.resetAllMocks())
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
  it('refreshSubmissions', () => {
    refreshSpeedGrader(props)
    expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID, false)
    expect(props.refreshEnrollments).toHaveBeenCalledWith(props.courseID)
    expect(props.refreshAssignment).toHaveBeenCalledWith(props.courseID, props.assignmentID)
    expect(props.getCourseEnabledFeatures).toHaveBeenCalledWith(props.courseID)
  })
  it('refreshSubmissions on group assignments', () => {
    refreshSpeedGrader({
      ...props,
      groupAssignment: { groupCategoryID: '334', gradeIndividually: false },
    })
    expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID, true)
    expect(props.refreshGroupsForCourse).toHaveBeenCalledWith(props.courseID)
    expect(props.refreshAssignment).toHaveBeenCalledWith(props.courseID, props.assignmentID)
    expect(props.getCourseEnabledFeatures).toHaveBeenCalledWith(props.courseID)
  })
  it('isRefreshing', () => {
    const isNot = isRefreshing(props)
    expect(isNot).toBeFalsy()

    const is = isRefreshing({ ...props, pending: true })
    expect(is).toBeTruthy()
  })
  it('shouldRefresh', () => {
    const should = shouldRefresh(props)
    expect(should).toBeTruthy()

    const submissions = [templates.submissionProps()]
    const shouldNot = shouldRefresh({ ...props, submissions })
    expect(shouldNot).toBeFalsy()
  })
})

test('mapStateToProps shuffles when anonymous grading is on', () => {
  const assignment = templates.assignment()
  const appState = templates.appState({
    entities: {
      submissions: {},
      assignments: {
        [assignment.id]: {
          data: assignment,
          anonymousGradingOn: true,
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

test('mapStateToProps shuffles when the assignment is an anonymous quiz', () => {
  const assignment = templates.assignment({ quiz_id: '1' })
  const quiz = templates.quiz({ id: '1', anonymous_submissions: true })
  const appState = templates.appState({
    entities: {
      submissions: {},
      assignments: {
        [assignment.id]: {
          data: assignment,
          anonymousGradingOn: true,
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

test('mapStateToProps shuffles when the course has anonymous_grading turned on', () => {
  const assignment = templates.assignment()
  const appState = templates.appState({
    entities: {
      submissions: {},
      assignments: {
        [assignment.id]: {
          data: assignment,
          anonymousGradingOn: false,
        },
      },
      courses: {
        '2': {
          enabledFeatures: ['anonymous_grading'],
        },
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
