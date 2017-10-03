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

/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { AssigneeSearch } from '../AssigneeSearch'
import renderer from 'react-test-renderer'
import { registerScreens } from '../../../../src/routing/register-screens'
import setProps from '../../../../test/helpers/setProps'
import { type AssigneeSearchProps } from '../map-state-to-props'

registerScreens({})

jest.mock('react-native-search-bar', () => require('../../../__mocks__/SearchBar').default)

const template = {
  ...require('../__template__/Assignee.js'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/enrollments'),
  ...require('../../../__templates__/section'),
  ...require('../../../__templates__/group'),
  ...require('../../../__templates__/helm'),
}

const defaultProps: AssigneeSearchProps = {
  courseID: template.course().id,
  assignmentID: template.assignment().id,
  assignment: template.assignment(),
  sections: [template.section()],
  enrollments: [template.enrollment()],
  groups: [template.group()],
  navigator: template.navigator(),
  handleSelectedAssignee: jest.fn(),
  refreshSections: jest.fn(),
  refreshEnrollments: jest.fn(),
  refreshGroupsForCategory: jest.fn(),
  onSelection: jest.fn(),
  pending: false,
}

test('render correctly', () => {
  let tree = renderer.create(
    <AssigneeSearch {...defaultProps} />
  )
  setProps(tree, { ...defaultProps })
  expect(tree.toJSON()).toMatchSnapshot()
})

test('render correctly', () => {
  let tree = renderer.create(
    <AssigneeSearch {...defaultProps} />
  )
  tree.getInstance().updateFilterString('student')
  expect(tree.toJSON()).toMatchSnapshot()
})

test('handles selection', () => {
  const fn = jest.fn()
  let search = renderer.create(
    <AssigneeSearch {...defaultProps} onSelection={fn} />
  ).getInstance()
  search.onRowPress()
  expect(fn).toHaveBeenCalled()
})

test('dismiss', () => {
  const fn = jest.fn()
  const navigator = template.navigator({
    dismiss: fn,
  })
  const picker = renderer.create(
    <AssigneeSearch {...defaultProps} navigator={navigator} />
  ).getInstance()
  picker.dismiss()
  expect(fn).toHaveBeenCalled()
})
