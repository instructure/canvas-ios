/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { Navigation } from 'react-native-navigation'
import { AssignmentDetailsEdit } from '../AssignmentDetailsEdit'
import setProps from '../../../../test/helpers/setProps'
import explore from '../../../../test/helpers/explore'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/react-native-navigation'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest.mock('react-native-navigation', () => ({
  Navigation: {
    dismissAllModals: jest.fn(),
  },
}))

jest.mock('../../../routing')

let course: any = template.course()
let assignment: any = template.assignment()

let defaultProps = {}
let onNavigatorEvent = () => {}
let doneButtonPressedProps = {}
const navigatorEventProps = { type: 'NavBarButtonPress', id: 'dismiss' }

beforeEach(() => {
  jest.clearAllMocks()

  defaultProps = {
    navigator: template.navigator(),
    courseID: course.courseID,
    assignmentID: assignment.assignmentID,
    refreshAssignmentDetails: (courseID: string, assignmentID: string) => {},
    assignmentDetails: assignment,
    pending: 0,
    stubSubmissionProgress: true,
    updateAssignment: jest.fn(),
  }
  onNavigatorEvent = () => {}
  doneButtonPressedProps = {
    ...defaultProps,
    navigator: template.navigator({
      dismissModal: jest.fn(),
      setOnNavigatorEvent: (handler) => { onNavigatorEvent = handler },
    }),
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
    dismissModal: jest.fn(),
  })

  let tree = renderer.create(
    <AssignmentDetailsEdit {...defaultProps} navigator={navigator} />
  )

  tree.getInstance().onNavigatorEvent({
    type: 'NavBarButtonPress',
    id: 'dismiss',
  })

  expect(defaultProps.updateAssignment).toHaveBeenCalledWith(undefined, defaultProps.assignmentDetails, defaultProps.assignmentDetails)
})

test('dismisses modal on done after assignment updates', () => {
  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />
  )
  let updateAssignment = jest.fn(() => {
    setProps(component, { pending: 0 })
  })
  component.update(<AssignmentDetailsEdit {...doneButtonPressedProps} updateAssignment={updateAssignment}/>)

  onNavigatorEvent(navigatorEventProps)

  expect(Navigation.dismissAllModals).toHaveBeenCalled()
})

test('modal saving... is shown on assignment update', () => {
  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />
  )

  let updateAssignment = jest.fn(() => {
    setProps(component, { pending: 1 })
  })
  component.update(<AssignmentDetailsEdit {...doneButtonPressedProps} updateAssignment={updateAssignment}/>)

  onNavigatorEvent(navigatorEventProps)

  let tree = component.toJSON()
  expect(tree).toMatchSnapshot()
})

test('dismisses modal on done after assignment updates', () => {
  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />
  )
  let updateAssignment = jest.fn(() => {
    setProps(component, { pending: 0 })
  })
  component.update(<AssignmentDetailsEdit {...doneButtonPressedProps} updateAssignment={updateAssignment}/>)

  onNavigatorEvent(navigatorEventProps)

  expect(Navigation.dismissAllModals).toHaveBeenCalled()
})

test('change title', () => {
  let expectedTitle = 'hello world title'

  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />
  )

  let tree = component.toJSON()
  let titleField = explore(tree).selectByID('titleInput') || {}
  titleField.props.onChangeText(expectedTitle)

  onNavigatorEvent(navigatorEventProps)

  let expected = { ...defaultProps.assignmentDetails, name: expectedTitle }

  expect(defaultProps.updateAssignment).toHaveBeenCalledWith(doneButtonPressedProps.courseID, expected, defaultProps.assignmentDetails)
})

