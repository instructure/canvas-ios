/**
 * @flow
 */

import { Alert } from 'react-native'
import React from 'react'
import { AssignmentDetails } from '../AssignmentDetails'
import timezoneMock from 'timezone-mock'
import explore from '../../../../test/helpers/explore'
import RCTSFSafariViewController from 'react-native-sfsafariviewcontroller'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/helm'),
  ...require('../../../api/canvas-api/__templates__/external-tool'),
  ...require('../../../api/canvas-api/__templates__/error'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest
  .mock('../../../routing')
  .mock('WebView', () => 'WebView')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('../components/SubmissionBreakdownGraphSection')

let course: any = template.course()
let assignment: any = template.assignment()

let defaultProps = {
  navigator: template.navigator(),
  courseID: course.id,
  assignmentID: assignment.assignmentID,
  refreshAssignmentDetails: (courseID: string, assignmentID: string) => {},
  assignmentDetails: assignment,
  pending: 0,
  stubSubmissionProgress: true,
  refresh: jest.fn(),
  refreshing: false,
  getSessionlessLaunchURL: jest.fn(),
}

beforeEach(() => {
  timezoneMock.register('US/Pacific')
})

afterEach(() => {
  timezoneMock.unregister()
})

test('renders', () => {
  let tree = renderer.create(
    <AssignmentDetails {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders with no submission types', () => {
  defaultProps.assignmentDetails = template.assignment({ submission_types: ['none'] })
  let tree = renderer.create(
    <AssignmentDetails {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders loading', () => {
  defaultProps.pending = 1
  let tree = renderer.create(
    <AssignmentDetails {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders without description', () => {
  let props = {
    ...defaultProps,
    assignmentDetails: { ...assignment, description: null },
  }
  let tree = renderer.create(
    <AssignmentDetails {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('calls navigator.show when the edit button is pressed', () => {
  let navigator = template.navigator({
    showModal: jest.fn(),
  })
  let tree = renderer.create(
    <AssignmentDetails {...defaultProps} navigator={navigator} />
  )

  tree.getInstance().editAssignment()

  expect(navigator.show).toHaveBeenCalledWith(
    `/courses/${defaultProps.courseID}/assignments/${defaultProps.assignmentDetails.id}/edit`,
    { modal: true }
  )
})

test('routes to the right place when due dates details is requested', () => {
  let navigator = template.navigator({
    show: jest.fn(),
  })
  let details = renderer.create(
    <AssignmentDetails {...defaultProps} navigator={navigator} />
  ).getInstance()
  details.viewDueDateDetails()
  expect(navigator.show).toHaveBeenCalledWith(
    `/courses/${defaultProps.courseID}/assignments/${defaultProps.assignmentDetails.id}/due_dates`,
    { modal: false },
  )
})

test('routes to the right place when submissions is tapped', () => {
  let navigator = template.navigator({
    push: jest.fn(),
  })
  let details = renderer.create(
    <AssignmentDetails {...defaultProps} navigator={navigator} />
  ).getInstance()
  details.viewAllSubmissions()
  expect(navigator.show).toHaveBeenCalledWith(
    `/courses/${defaultProps.courseID}/assignments/${defaultProps.assignmentDetails.id}/submissions`
  )
})

test('routes to the right place when submissions dial is tapped', () => {
  let navigator = template.navigator({
    push: jest.fn(),
  })
  let details = renderer.create(
    <AssignmentDetails {...defaultProps} navigator={navigator} />
  ).getInstance()
  details.onSubmissionDialPress('graded')
  expect(navigator.show).toHaveBeenCalledWith(
    `/courses/${defaultProps.courseID}/assignments/${defaultProps.assignmentDetails.id}/submissions`,
    { modal: false },
    { filterType: 'graded' }
  )
})

describe('external tool', () => {
  describe('happy path', () => {
    beforeEach(() => {
      RCTSFSafariViewController.open = jest.fn()
    })
    const url = 'https://canvas.instructure.com/external_tool'
    const props = {
      ...defaultProps,
      getSessionlessLaunchURL: jest.fn(() => Promise.resolve(url)),
      assignmentDetails: template.assignment({
        submission_types: ['external_tool'],
      }),
    }
    const tree = renderer.create(
      <AssignmentDetails {...props} />
    ).toJSON()

    it('launches from submission types', async () => {
      const submissionTypes: any = explore(tree).selectByID('assignment-details.assignment-section.submission-type')
      await submissionTypes.props.onPress()
      expect(RCTSFSafariViewController.open).toHaveBeenCalledWith(url)
    })

    it('launches from button', async () => {
      const button: any = explore(tree).selectByID('assignment-details.launch-external-tool.button')
      await button.props.onPress()
      expect(RCTSFSafariViewController.open).toHaveBeenCalledWith(url)
    })
  })

  describe('sad path', () => {
    it('shows an alert', async () => {
      // $FlowFixMe
      Alert.alert = jest.fn()
      const props = {
        ...defaultProps,
        assignmentDetails: template.assignment({
          submission_types: ['external_tool'],
        }),
        getSessionlessLaunchURL: jest.fn(() => Promise.reject(template.error('Network error'))),
      }
      const tree = renderer.create(
        <AssignmentDetails {...props} />
      ).toJSON()
      const button: any = explore(tree).selectByID('assignment-details.launch-external-tool.button')
      await button.props.onPress()
      expect(Alert.alert).toHaveBeenCalledWith('Unexpected Error', 'Network error')
    })
  })
})
