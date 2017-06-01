// @flow

import React from 'react'
import {
  SpeedGrader,
  mapStateToProps,
  refreshSpeedGrader,
  shouldRefresh,
  isRefreshing,
} from '../SpeedGrader'
import renderer from 'react-test-renderer'

jest.mock('../components/GradePicker')
jest.mock('../components/Header')
jest.mock('../components/FilesTab')
jest.mock('../../../common/components/BottomDrawer')

const templates = {
  ...require('../../../api/canvas-api/__templates__/submissions'),
  ...require('../../../api/canvas-api/__templates__/assignments'),
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
  pending: false,
  refreshing: false,
  refresh: jest.fn(),
  refreshSubmissions: jest.fn(),
  navigator: templates.navigator(),
  submissions: [],
  submissionEntities: {},
  resetDrawer: jest.fn(),
  assignmentSubmissionTypes: ['none'],
}

describe('SpeedGrader', () => {
  it('renders', () => {
    let tree = renderer.create(
      <SpeedGrader {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('shows the loading spinner when there are no submissions', () => {
    let tree = renderer.create(
      <SpeedGrader {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('shows the loading spinner when pending and not refreshing', () => {
    let tree = renderer.create(
      <SpeedGrader {...defaultProps} pending={true} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders submissions if there are some', () => {
    const submissions = [templates.submissionProps()]
    const props = { ...defaultProps, submissions }
    let tree = renderer.create(
      <SpeedGrader {...props} />
    ).toJSON()

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
    refreshEnrollments: jest.fn(),
    refreshAssignment: jest.fn(),
    resetDrawer: jest.fn(),
    assignmentSubmissionTypes: ['none'],
    submissions: [],
    submissionEntities: {},
    refresh: jest.fn(),
    refreshing: false,
    pending: false,
    navigator: templates.navigator(),
  }
  it('refreshSubmissions', () => {
    refreshSpeedGrader(props)
    expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID)
    expect(props.refreshEnrollments).toHaveBeenCalledWith(props.courseID)
    expect(props.refreshAssignment).toHaveBeenCalledWith(props.courseID, props.assignmentID)
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

test('mapStateToProps filters', () => {
  const assignment = templates.assignment()
  const appState = templates.appState({
    entities: {
      submissions: {},
      assignments: {
        [assignment.id]: {
          data: assignment,
        },
      },
    },
  })
  expect(mapStateToProps(appState, {
    assignmentID: assignment.id,
    courseID: '2',
    userID: '3',
    selectedFilter: {
      filter: {
        type: 'notsubmitted',
        title: 'Who Cares?',
        filterFunc: subs => subs.filter(sub => sub.status === 'missing'),
      },
    },
  })).toEqual({
    pending: false,
    submissions: [
      templates.submissionProps({ status: 'missing' }),
    ],
    submissionEntities: {},
    assignmentSubmissionTypes: assignment.submission_types,
  })
})
