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
import shuffle from 'knuth-shuffle-seeded'

jest.mock('../components/GradePicker')
jest.mock('../components/Header')
jest.mock('../components/FilesTab')
jest.mock('../../../common/components/BottomDrawer')
jest.mock('knuth-shuffle-seeded', () => jest.fn())

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

  it('renders with a filter', () => {
    let props = {
      ...defaultProps,
      submissions: [templates.submissionProps(), templates.submissionProps({ status: 'missing' })],
      selectedFilter: {
        filter: {
          type: 'notsubmitted',
          title: 'Who Cares?',
          filterFunc: subs => subs.filter(sub => sub.status === 'missing'),
        },
      },
    }
    let tree = renderer.create(
      <SpeedGrader {...props} />
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
  }
  it('refreshSubmissions', () => {
    refreshSpeedGrader(props)
    expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID, false)
    expect(props.refreshEnrollments).toHaveBeenCalledWith(props.courseID)
    expect(props.refreshAssignment).toHaveBeenCalledWith(props.courseID, props.assignmentID)
  })
  it('refreshSubmissions on group assignments', () => {
    refreshSpeedGrader({
      ...props,
      groupAssignment: { groupCategoryID: '334', gradeIndividually: false },
    })
    expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID, true)
    expect(props.refreshGroupsForCourse).toHaveBeenCalledWith(props.courseID)
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
    },
  })
  mapStateToProps(appState, {
    assignmentID: assignment.id,
    courseID: '2',
    userID: '3',
  })
  expect(shuffle).toHaveBeenCalled()
})
