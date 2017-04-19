/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { AssignmentDetails } from '../AssignmentDetails'
import { route } from '../../../routing'
import timezoneMock from 'timezone-mock'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/react-native-navigation'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest.mock('../../../routing')
jest.mock('WebView', () => 'WebView')

let course: any = template.course()
let assignment: any = template.assignment()

let defaultProps = {
  navigator: template.navigator(),
  courseID: course.courseID,
  assignmentID: assignment.assignmentID,
  refreshAssignmentDetails: (courseID: string, assignmentID: string) => {},
  assignmentDetails: assignment,
  pending: 0,
  stubSubmissionProgress: true,
  refresh: jest.fn(),
  refreshing: false,
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

test('renders loading', () => {
  defaultProps.pending = 1
  let tree = renderer.create(
    <AssignmentDetails {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders locked', () => {
  let lockAt = new Date()
  lockAt.setDate(lockAt.getDate() - 1)
  defaultProps.assignmentDetails.lockAt = lockAt.getTime()
  defaultProps.assignmentDetails.lockAt = '2017-01-01T05:59:59Z'

  let tree = renderer.create(
    <AssignmentDetails {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('calls navigator.showModal when the edit button is pressed', () => {
  let navigator = template.navigator({
    showModal: jest.fn(),
  })
  let tree = renderer.create(
    <AssignmentDetails {...defaultProps} navigator={navigator} />
  )

  tree.getInstance().onNavigatorEvent({
    type: 'NavBarButtonPress',
    id: 'edit',
  })

  expect(navigator.showModal).toHaveBeenCalledWith({
    ...route(`/courses/${defaultProps.courseID}/assignments/${defaultProps.assignmentDetails.id}/edit`),
    animationType: 'slide-up',
  })
})
