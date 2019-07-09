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
