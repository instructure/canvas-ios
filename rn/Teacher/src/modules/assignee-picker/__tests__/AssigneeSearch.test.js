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

import { shallow } from 'enzyme'
import 'react-native'
import React from 'react'
import { AssigneeSearch } from '../AssigneeSearch'
import renderer from 'react-test-renderer'
import setProps from '../../../../test/helpers/setProps'
import { type AssigneeSearchProps } from '../map-state-to-props'
import * as template from '../../../__templates__'

jest.mock('react-native-search-bar', () => require('../../../__mocks__/SearchBar').default)

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

test('renders student names', () => {
  let props = {
    ...defaultProps,
    enrollments: [
      template.enrollment({
        user: template.user({
          id: '1',
          name: 'Alfredo',
          pronouns: null,
        }),
      }),
      template.enrollment({
        user: template.user({
          id: '2',
          name: 'Eve',
          pronouns: 'She/Her',
        }),
      }),
    ],
  }
  let tree = shallow(<AssigneeSearch {...props} />)
  let list = tree.find('SectionList')
  let sections = list.prop('sections')
  let user1Row = shallow(list.prop('renderItem')({ item: sections[3].data[0], index: 0 }))
  expect(user1Row.find('[testID="AssigneeRow.student-1.name"]').prop('children')).toEqual('Alfredo')
  let user2Row = shallow(list.prop('renderItem')({ item: sections[3].data[1], index: 1 }))
  expect(user2Row.find('[testID="AssigneeRow.student-2.name"]').prop('children')).toEqual('Eve (She/Her)')
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
