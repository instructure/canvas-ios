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
import { AssigneePicker } from '../AssigneePicker'
import { type AssigneePickerProps } from '../map-state-to-props'
import renderer from 'react-test-renderer'
import setProps from '../../../../test/helpers/setProps'
import { cloneDeep } from 'lodash'

const template = {
  ...require('../__template__/Assignee.js'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/helm'),
}

const assignees = [
  template.enrollmentAssignee(),
  template.enrollmentAssignee({ imageURL: null, id: '9909342324234' }),
  template.groupAssignee(),
]
const defaultProps: AssigneePickerProps = {
  assignees,
  courseID: template.course().id,
  assignmentID: template.assignment().id,
  navigator: template.navigator(),
  handleSelectedAssignee: jest.fn(),
  refreshSections: jest.fn(),
  refreshUsers: jest.fn(),
  refreshGroup: jest.fn(),
}

test('render correctly', () => {
  let tree = renderer.create(
    <AssigneePicker {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('new assignee props should update correctly', () => {
  const props = cloneDeep(defaultProps)
  const assignees = cloneDeep(props.assignees)
  let picker = renderer.create(
    <AssigneePicker {...props} />
  )

  assignees[0].name = 'Solaire of Astora'
  delete assignees[1]
  assignees.push(template.sectionAssignee())
  assignees.push(template.groupAssignee())
  setProps(picker, { assignees })
  expect(picker.getInstance().state.selected[0]).toMatchObject({
    name: 'Solaire of Astora',
  })
  expect(picker.getInstance().state.selected).toHaveLength(4)
})

test('cancel', () => {
  const fn = jest.fn()
  const navigator = template.navigator({
    dismiss: fn,
  })
  const picker = renderer.create(
    <AssigneePicker {...defaultProps} navigator={navigator} />
  ).getInstance()
  picker.dismiss()
  expect(fn).toHaveBeenCalled()
})

test('done', () => {
  const fn = jest.fn()
  const navigator = template.navigator({
    dismiss: fn,
  })
  const picker = renderer.create(
    <AssigneePicker {...defaultProps} navigator={navigator} />
  ).getInstance()
  picker.done()
  expect(fn).toHaveBeenCalled()
})

test('done with callback', () => {
  const callback = jest.fn()
  const fn = jest.fn(() => {
    callback()
  })
  const navigator = template.navigator({
    dismiss: fn,
  })
  const picker = renderer.create(
    <AssigneePicker {...defaultProps} navigator={navigator} callback={callback} />
  ).getInstance()
  picker.done()
  expect(callback).toHaveBeenCalled()
})

test('add assignee function', () => {
  const fn = jest.fn()
  const navigator = template.navigator({
    show: fn,
  })
  const picker = renderer.create(
    <AssigneePicker {...defaultProps} navigator={navigator} />
  ).getInstance()
  picker.addAssignee()
  expect(fn).toHaveBeenCalled()
})

test('handles adding', () => {
  let assignee = template.enrollmentAssignee({
    id: '999999',
  })
  let picker = renderer.create(
    <AssigneePicker {...defaultProps} />
  ).getInstance()
  picker.handleSelectedAssignee(assignee)
  expect(picker.state.selected.length).toEqual(4)
})

test('cannot add the same assignee two times in a row', () => {
  let assignee = template.enrollmentAssignee({
    id: '999999',
  })
  let picker = renderer.create(
    <AssigneePicker {...defaultProps} />
  ).getInstance()
  picker.handleSelectedAssignee(assignee)
  picker.handleSelectedAssignee(assignee)
  expect(picker.state.selected.length).toEqual(4)
})

test('handles removing', () => {
  let assignee = defaultProps.assignees[0]
  let picker = renderer.create(
    <AssigneePicker {...defaultProps} />
  ).getInstance()
  picker.deleteAssignee(assignee)
  expect(picker.state.selected.length).toEqual(2)
})
