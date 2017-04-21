/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { AssigneeSearch } from '../AssigneeSearch'
import renderer from 'react-test-renderer'
import { registerScreens } from '../../../../src/routing/register-screens'
import setProps from '../../../../test/helpers/setProps'

registerScreens({})

jest.mock('react-native-search-bar', () => require('../../../__mocks__/SearchBar').default)

const template = {
  ...require('../__template__/Assignee.js'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../api/canvas-api/__templates__/enrollments'),
  ...require('../../../api/canvas-api/__templates__/section'),
  ...require('../../../__templates__/react-native-navigation'),
}

const defaultProps = {
  courseID: template.course().id,
  sections: [template.section()],
  enrollments: [template.enrollment()],
  navigator: template.navigator(),
  handleSelectedAssignee: jest.fn(),
  refreshSections: jest.fn(),
  refreshEnrollments: jest.fn(),
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
    dismissModal: fn,
  })
  const picker = renderer.create(
    <AssigneeSearch {...defaultProps} navigator={navigator} />
  ).getInstance()
  picker.onNavigatorEvent({ type: 'NavBarButtonPress', id: 'cancel' })
  expect(fn).toHaveBeenCalled()
})
