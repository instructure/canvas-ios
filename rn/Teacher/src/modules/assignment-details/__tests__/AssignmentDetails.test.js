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

/* eslint-disable flowtype/require-valid-file-annotation */

import { Alert } from 'react-native'
import React from 'react'
import { AssignmentDetails } from '../AssignmentDetails'
import explore from '../../../../test/helpers/explore'
import RCTSFSafariViewController from 'react-native-sfsafariviewcontroller'
import renderer from 'react-test-renderer'
import { setSession } from '../../../canvas-api'
import { defaultErrorTitle } from '../../../redux/middleware/error-handler'

const template = {
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/helm'),
  ...require('../../../__templates__/external-tool'),
  ...require('../../../__templates__/error'),
  ...require('../../../__templates__/session'),
}

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
  course: course,
  assignmentID: assignment.id,
  refreshAssignmentDetails: (courseID: string, assignmentID: string) => {},
  assignmentDetails: assignment,
  pending: 0,
  stubSubmissionProgress: true,
  refresh: jest.fn(),
  refreshing: false,
  getSessionlessLaunchURL: jest.fn(),
}

beforeAll(() => setSession(template.session()))

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

test('renders with no assignment', () => {
  let props = {
    ...defaultProps,
    assignmentDetails: null,
  }
  let tree = renderer.create(
    <AssignmentDetails {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders as a designer', () => {
  let tree = renderer.create(
    <AssignmentDetails {...defaultProps} showSubmissionSummary={false} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders with not_graded submission type', () => {
  defaultProps.assignmentDetails = template.assignment({ submission_types: ['not_graded'] })
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

    setSession(template.session())
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
      expect(Alert.alert).toHaveBeenCalledWith(defaultErrorTitle(), 'Network error')
    })
  })
})
