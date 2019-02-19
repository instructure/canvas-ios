//
// Copyright (C) 2018-present Instructure, Inc.
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

import React from 'react'
import { AssignmentDetails } from '../AssignmentDetails'
import { shallow } from 'enzyme'
import app from '../../app'
import * as template from '../../../__templates__'

jest
  .mock('../../../routing')
  .mock('WebView', () => 'WebView')
  .mock('TouchableHighlight', () => 'TouchableHighlight')

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

test('renders for a student', () => {
  app.setCurrentApp('student')
  let tree = shallow(
    <AssignmentDetails {...defaultProps} />
  )
  expect(tree).toMatchSnapshot()
  expect(tree.find('[testID="assignment-details.assignment-section.due"]')).toHaveLength(1)
  expect(tree.find('[testID="assignment-details.assignment-section.due"]').prop('title')).toEqual('Due')
})

test('renders without description', () => {
  app.setCurrentApp('student')
  let props = {
    ...defaultProps,
    assignmentDetails: { ...assignment, description: null },
  }
  let tree = shallow(
    <AssignmentDetails {...props} />
  )
  expect(tree).toMatchSnapshot()
  expect(tree.find('[testID="assignment-details.description-default-view"]').prop('text')).toEqual("This assignment doesn't have a description.")
})

test('renders without a due date', () => {
  app.setCurrentApp('student')
  let props = {
    ...defaultProps,
    assignmentDetails: { ...assignment, due_at: null },
  }
  let tree = shallow(
    <AssignmentDetails {...props} />
  )
  expect(tree).toMatchSnapshot()
  expect(tree.find('[testID="assignment-details.assignment-section.due"]').prop('title')).toEqual('Due')
  expect(tree.find('[testID="assignment-details.assignment-section.due"] Text').props().children).toEqual('No Due Date')
})

test('renders a single file type', () => {
  app.setCurrentApp('student')
  let props = {
    ...defaultProps,
    assignmentDetails: { ...assignment, allowed_extensions: ['pdf'] },
  }
  let tree = shallow(
    <AssignmentDetails {...props} />
  )
  expect(tree).toMatchSnapshot()
  expect(tree.find('[testID="assignment-details.assignment-section.file-types"]').prop('title')).toEqual('File Types')
  expect(tree.find('[testID="assignment-details.assignment-section.file-types"] Text').props().children).toEqual('pdf')
})

test('renders multiple file types', () => {
  app.setCurrentApp('student')
  let props = {
    ...defaultProps,
    assignmentDetails: { ...assignment, allowed_extensions: ['pdf', 'txt', 'mp4'] },
  }
  let tree = shallow(
    <AssignmentDetails {...props} />
  )
  expect(tree).toMatchSnapshot()
  expect(tree.find('[testID="assignment-details.assignment-section.file-types"]').prop('title')).toEqual('File Types')
  expect(tree.find('[testID="assignment-details.assignment-section.file-types"] Text').props().children).toEqual('pdf, txt and mp4')
})

test('renders even if there is fake data', () => {
  app.setCurrentApp('student')
  let props = {
    ...defaultProps,
    assignmentDetails: { ...assignment, allowed_extensions: { mp4: 'mp4' } },
  }
  let tree = shallow(
    <AssignmentDetails {...props} />
  )
  expect(tree).toMatchSnapshot()
  expect(tree.find('[testID="assignment-details.assignment-section.file-types"]')).toHaveLength(0)
})
