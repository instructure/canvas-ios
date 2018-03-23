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

import { shallow } from 'enzyme'
import { NativeModules } from 'react-native'
import React from 'react'
import { AssignmentDetailsEdit } from '../AssignmentDetailsEdit'
import setProps from '../../../../test/helpers/setProps'
import explore from '../../../../test/helpers/explore'

const template = {
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/helm'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('LayoutAnimation', () => ({
    Presets: {
      spring: null,
    },
    create: jest.fn(),
    configureNext: jest.fn(),
    easeInEaseOut: jest.fn(),
    Types: { linear: null },
    Properties: { opacity: null },
  }))
  .mock('WebView', () => 'WebView')
  .mock('Button', () => 'Button')
  .mock('../../../routing/Screen')
  .mock('../../assignment-details/components/AssignmentDatesEditor', () => 'AssignmentDatesEditor')

let course: Course
let assignment: Assignment

let defaultProps = {}
let doneButtonPressedProps = {}

const options = {
  createNodeMock: ({ type }) => {
    if (type === 'AssignmentDatesEditor') {
      return {
        validate: jest.fn().mockReturnValue(true),
        updateAssignment: jest.fn(a => a),
      }
    }
  },
}

beforeEach(() => {
  jest.clearAllMocks()

  course = template.course()
  assignment = template.assignment({
    published: true,
    unpublishable: true,
  })

  defaultProps = {
    navigator: template.navigator(),
    courseID: course.id,
    assignmentID: assignment.id,
    refreshAssignmentDetails: (courseID: string, assignmentID: string) => {},
    assignmentDetails: assignment,
    pending: false,
    stubSubmissionProgress: true,
    updateAssignment: jest.fn(),
    refreshAssignment: jest.fn(),
  }
  doneButtonPressedProps = {
    ...defaultProps,
    navigator: template.navigator({
      dismiss: jest.fn(),
    }),
    cancelAssignmentUpdate: jest.fn(),
  }
})

test('renders', () => {
  let tree = renderer.create(
    <AssignmentDetailsEdit {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('calls updateAssignment when the done button is pressed', () => {
  let navigator = template.navigator({
    dismiss: jest.fn(),
  })

  let tree = renderer.create(
    <AssignmentDetailsEdit {...defaultProps} navigator={navigator} />, options
  )

  tree.getInstance().actionDonePressed()
  expect(defaultProps.updateAssignment).toHaveBeenCalledWith(course.id, defaultProps.assignmentDetails, defaultProps.assignmentDetails)
})

test('dismisses modal on done after assignment updates', () => {
  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />, options
  )
  let updateAssignment = jest.fn(() => {
    setProps(component, { pending: false })
  })
  component.update(<AssignmentDetailsEdit {...doneButtonPressedProps} updateAssignment={updateAssignment}/>)

  component.getInstance().actionDonePressed()

  expect(doneButtonPressedProps.navigator.dismissAllModals).toHaveBeenCalled()
})

test('modal saving is shown on assignment update', () => {
  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />, options
  )

  let updateAssignment = jest.fn(() => {
    setProps(component, { pending: true })
  })
  component.update(<AssignmentDetailsEdit {...doneButtonPressedProps} updateAssignment={updateAssignment}/>)

  component.getInstance().actionDonePressed()

  let tree = component.toJSON()
  expect(tree).toMatchSnapshot()
})

test('error occurs when done pressed', () => {
  jest.useFakeTimers()

  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />, options
  )

  let updateAssignment = jest.fn(() => {
    setProps(component, { pending: false, error: { response: { data: { errors: [{ message: 'error occurred' }] } } } })
  })
  component.update(<AssignmentDetailsEdit {...doneButtonPressedProps} updateAssignment={updateAssignment}/>)

  component.getInstance().actionDonePressed()

  jest.runAllTimers()

  let tree = component.toJSON()
  expect(tree).toMatchSnapshot()
})

test('dismisses modal on cancel', () => {
  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />, options
  )
  let updateAssignment = jest.fn(() => {
    setProps(component, { pending: false })
  })
  component.update(<AssignmentDetailsEdit {...doneButtonPressedProps} updateAssignment={updateAssignment}/>)
  component.getInstance().actionCancelPressed()
  expect(doneButtonPressedProps.navigator.dismiss).toHaveBeenCalled()
})

test('"displays grade as" can be selected using picker', () => {
  let selectedValue = 'not_graded'
  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />, options
  )

  let row: any = explore(component.toJSON()).selectByID('assignment-details.toggle-display-grade-as-picker')
  row.props.onPress()
  let tree = component.toJSON()
  let picker = explore(tree).selectByID('assignmentPicker') || {}
  picker.props.onValueChange(selectedValue)

  component.getInstance().actionDonePressed()

  let expected = { ...defaultProps.assignmentDetails, grading_type: selectedValue }
  expect(defaultProps.updateAssignment).toHaveBeenCalledWith(doneButtonPressedProps.courseID, expected, defaultProps.assignmentDetails)
})

test('edit description', () => {
  defaultProps.assignmentDetails.description = 'i am a description'
  const navigator = template.navigator({
    show: jest.fn(),
  })
  const tree = renderer.create(
    <AssignmentDetailsEdit {...defaultProps} navigator={navigator} />
  ).toJSON()
  const editDescription: any = explore(tree).selectByID('edit-description')
  editDescription.props.onPress()
  expect(navigator.show).toHaveBeenCalledWith('/rich-text-editor', { modal: true, modalPresentationStyle: 'fullscreen' }, {
    defaultValue: 'i am a description',
    onChangeValue: expect.any(Function),
    showToolbar: 'always',
    placeholder: 'Description',
    attachmentUploadPath: '/courses/1/files',
  })
})

it('focuses unmetRequirementBanner after it shows', () => {
  jest.useFakeTimers()
  defaultProps.assignmentDetails.name = ''
  const component = renderer.create(
    <AssignmentDetailsEdit {...defaultProps} />, options
  )
  const doneBtn: any = explore(component.toJSON()).selectRightBarButton('edit-assignment.dismiss-btn')
  doneBtn.action()
  jest.runAllTimers()
  expect(NativeModules.NativeAccessibility.focusElement).toHaveBeenCalledWith(`assignmentDetailsEdit.unmet-requirement-banner`)
})

test('saving invalid name displays banner', () => {
  defaultProps.assignmentDetails.name = ''
  const component = renderer.create(
    <AssignmentDetailsEdit {...defaultProps} />, options
  )
  const doneBtn: any = explore(component.toJSON()).selectRightBarButton('edit-assignment.dismiss-btn')
  doneBtn.action()
  expect(component.toJSON()).toMatchSnapshot()
})

test('saving invalid points possible displays banner', () => {
  // $FlowFixMe
  defaultProps.assignmentDetails.points_possible = 'D'
  const component = renderer.create(
    <AssignmentDetailsEdit {...defaultProps} />, options
  )
  const doneBtn: any = explore(component.toJSON()).selectRightBarButton('edit-assignment.dismiss-btn')
  doneBtn.action()
  expect(component.toJSON()).toMatchSnapshot()
})

test('saving invalid dates displays banner', () => {
  // $FlowFixMe
  defaultProps.assignmentDetails.all_dates = {
    due_at: '2017-06-01T07:59:00Z',
    lock_at: '2017-06-01T05:59:00Z',
  }
  const component = renderer.create(
    <AssignmentDetailsEdit {...defaultProps} />, options
  )
  const doneBtn: any = explore(component.toJSON()).selectRightBarButton('edit-assignment.dismiss-btn')
  doneBtn.action()
  expect(component.toJSON()).toMatchSnapshot()
})

test('saving negative points possible displays banner', () => {
  defaultProps.assignmentDetails.points_possible = -1
  const component = renderer.create(
    <AssignmentDetailsEdit {...defaultProps} />, options
  )
  const doneBtn: any = explore(component.toJSON()).selectRightBarButton('edit-assignment.dismiss-btn')
  doneBtn.action()
  expect(component.toJSON()).toMatchSnapshot()
})

test('change title', () => {
  testInputField('titleInput', 'hello world title', 'name')
})

test('change points', () => {
  testInputField('assignmentDetails.edit.points_possible.input', 11, 'points_possible')
})

test('change published', () => {
  testSwitchToggled('published', true, 'published')
})

test('renders publish switch if not published', () => {
  let props = {
    ...defaultProps,
    assignmentDetails: {
      ...assignment,
      published: false,
      unpublishable: false,
    },
  }
  const tree = shallow(<AssignmentDetailsEdit {...props} />)
  expect(tree.find('[identifier="published"]')).toHaveLength(1)
})

test('renders publish switch if unpublishable', () => {
  let props = {
    ...defaultProps,
    assignmentDetails: {
      ...assignment,
      published: true,
      unpublishable: true,
    },
  }
  const tree = shallow(<AssignmentDetailsEdit {...props} />)
  expect(tree.find('[identifier="published"]')).toHaveLength(1)
})

test('does not render publish switch if unpublishable', () => {
  let props = {
    ...defaultProps,
    assignmentDetails: {
      ...assignment,
      published: true,
      unpublishable: false,
    },
  }
  const tree = shallow(<AssignmentDetailsEdit {...props} />)
  expect(tree.find('[identifier="published"]')).toHaveLength(0)
})

function testInputField (ref: string, input: any, assignmentField: string) {
  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />, options
  )

  let tree = component.toJSON()
  let field = explore(tree).selectByID(ref) || {}
  field.props.onChangeText(input)

  component.getInstance().actionDonePressed()

  let expected = { ...defaultProps.assignmentDetails, [assignmentField]: input }

  expect(defaultProps.updateAssignment).toHaveBeenCalledWith(doneButtonPressedProps.courseID, expected, defaultProps.assignmentDetails)
}

function testSwitchToggled (ref: string, input: any, assignmentField: string) {
  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />, options
  )

  let tree = component.toJSON()
  let field = explore(tree).selectByID(ref) || {}
  field.props.onValueChange(input)

  component.getInstance().actionDonePressed()

  let expected = { ...defaultProps.assignmentDetails, [assignmentField]: input }
  expect(defaultProps.updateAssignment).toHaveBeenCalledWith(doneButtonPressedProps.courseID, expected, defaultProps.assignmentDetails)
}
