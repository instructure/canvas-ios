/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { AssignmentDetailsEdit } from '../AssignmentDetailsEdit'
import setProps from '../../../../test/helpers/setProps'
import explore from '../../../../test/helpers/explore'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/helm'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest
  .mock('PickerIOS', () => require('../../../__mocks__/PickerIOS').default)
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

let course: Course
let assignment: Assignment

let defaultProps = {}
let doneButtonPressedProps = {}

beforeEach(() => {
  jest.clearAllMocks()

  course = template.course()
  assignment = template.assignment()

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
    <AssignmentDetailsEdit {...defaultProps} navigator={navigator} />
  )

  tree.getInstance().actionDonePressed()
  expect(defaultProps.updateAssignment).toHaveBeenCalledWith(course.id, defaultProps.assignmentDetails, defaultProps.assignmentDetails)
})

test('dismisses modal on done after assignment updates', () => {
  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />
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
    <AssignmentDetailsEdit {...doneButtonPressedProps} />
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
    <AssignmentDetailsEdit {...doneButtonPressedProps} />
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
    <AssignmentDetailsEdit {...doneButtonPressedProps} />
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
    <AssignmentDetailsEdit {...doneButtonPressedProps} />
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
  expect(navigator.show).toHaveBeenCalledWith('/rich-text-editor', { modal: false }, {
    defaultValue: 'i am a description',
    onChangeValue: expect.any(Function),
  })
})

test('change title', () => {
  testInputField('titleInput', 'hello world title', 'name')
})

test('change points', () => {
  testInputField('pointsInput', 1, 'points_possible')
})

test('change published', () => {
  testSwitchToggled('published', true, 'published')
})

function testInputField (ref: string, input: any, assignmentField: string) {
  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />
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
    <AssignmentDetailsEdit {...doneButtonPressedProps} />
  )

  let tree = component.toJSON()
  let field = explore(tree).selectByID(ref) || {}
  field.props.onValueChange(input)

  component.getInstance().actionDonePressed()

  let expected = { ...defaultProps.assignmentDetails, [assignmentField]: input }
  expect(defaultProps.updateAssignment).toHaveBeenCalledWith(doneButtonPressedProps.courseID, expected, defaultProps.assignmentDetails)
}
