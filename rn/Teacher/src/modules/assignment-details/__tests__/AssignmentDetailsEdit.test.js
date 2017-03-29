/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { AssignmentDetailsEdit } from '../AssignmentDetailsEdit'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/react-native-navigation'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest.mock('../../../routing')

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
}

test('renders', () => {
  let tree = renderer.create(
    <AssignmentDetailsEdit {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('calls navigator.dismissModal when the done button is pressed', () => {
  let navigator = template.navigator({
    dismissModal: jest.fn(),
  })

  let tree = renderer.create(
    <AssignmentDetailsEdit {...defaultProps} navigator={navigator} />
  )

  tree.getInstance().onNavigatorEvent({
    type: 'NavBarButtonPress',
    id: 'dismiss',
  })

  expect(navigator.dismissModal).toHaveBeenCalledWith()
})
