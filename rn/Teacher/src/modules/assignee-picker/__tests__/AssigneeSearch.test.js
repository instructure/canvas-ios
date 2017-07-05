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
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/enrollments'),
  ...require('../../../api/canvas-api/__templates__/section'),
  ...require('../../../api/canvas-api/__templates__/group'),
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
