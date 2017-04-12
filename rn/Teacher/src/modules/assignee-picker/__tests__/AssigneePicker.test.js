/**
 * @flow
 */

import 'react-native'
import React from 'react'
import AssigneePicker from '../AssigneePicker'
import renderer from 'react-test-renderer'
import { registerScreens } from '../../../../src/routing/register-screens'

registerScreens({})

const template = {
  ...require('../__template__/Assignee.js'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/react-native-navigation'),
}

const defaultProps = {
  assignees: [template.assignee(), template.assignee({ imageURL: null, id: '9909342324234' })],
  courseID: template.course().id,
  navigator: template.navigator(),
  handleSelectedAssignee: jest.fn(),
}

test('render correctly', () => {
  let tree = renderer.create(
    <AssigneePicker {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('dismiss', () => {
  const fn = jest.fn()
  const navigator = template.navigator({
    dismissModal: fn,
  })
  const picker = renderer.create(
    <AssigneePicker {...defaultProps} navigator={navigator} />
  ).getInstance()
  picker.onNavigatorEvent({ type: 'NavBarButtonPress', id: 'cancel' })
  expect(fn).toHaveBeenCalled()
})

test('add assignee function', () => {
  const fn = jest.fn()
  const navigator = template.navigator({
    showModal: fn,
  })
  const picker = renderer.create(
    <AssigneePicker {...defaultProps} navigator={navigator} />
  ).getInstance()
  picker.addAssignee()
  expect(fn).toHaveBeenCalled()
})

test('handles adding', () => {
  let assignee = template.assignee({
    id: '999999',
  })
  let picker = renderer.create(
    <AssigneePicker {...defaultProps} />
  ).getInstance()
  picker.handleSelectedAssignee(assignee)
  expect(picker.state.selected.length).toEqual(3)
})

test('handles removing', () => {
  let assignee = defaultProps.assignees[0]
  let picker = renderer.create(
    <AssigneePicker {...defaultProps} />
  ).getInstance()
  picker.deleteAssignee(assignee)
  expect(picker.state.selected.length).toEqual(1)
})
