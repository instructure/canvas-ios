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

jest
  .mock('PickerIOS', () => require('../../../__mocks__/PickerIOS').default)
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('LayoutAnimation', () => ({
    create: jest.fn(),
    configureNext: jest.fn(),
    easeInEaseOut: jest.fn(),
    Types: { linear: null },
    Properties: { opacity: null },
  }))
  .mock('../../../routing')
  .mock('react-native-navigation', () => ({
    Navigation: {
      dismissAllModals: jest.fn(),
    },
  }))
  .mock('WebView', () => 'WebView')
  .mock('../../assignment-description/AssignmentDescription')
  .mock('../../../common/components/rich-text-editor/RichTextEditor')
  .mock('Button', () => 'Button')

let course: any = template.course()
let assignment: any = template.assignment()

let defaultProps = {}
let onNavigatorEvent = () => {}
let doneButtonPressedProps = {}
const navigatorDismissEventProps = { type: 'NavBarButtonPress', id: 'dismiss' }
const navigatorCancelEventProps = { type: 'NavBarButtonPress', id: 'cancel' }

beforeEach(() => {
  jest.clearAllMocks()

  defaultProps = {
    navigator: template.navigator(),
    courseID: course.courseID,
    assignmentID: assignment.assignmentID,
    refreshAssignmentDetails: (courseID: string, assignmentID: string) => {},
    assignmentDetails: assignment,
    pending: false,
    stubSubmissionProgress: true,
    updateAssignment: jest.fn(),
    refreshAssignment: jest.fn(),
  }
  onNavigatorEvent = () => {}
  doneButtonPressedProps = {
    ...defaultProps,
    navigator: template.navigator({
      dismissModal: jest.fn(),
      setOnNavigatorEvent: (handler) => { onNavigatorEvent = handler },
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
    setProps(component, { pending: false })
  })
  component.update(<AssignmentDetailsEdit {...doneButtonPressedProps} updateAssignment={updateAssignment}/>)

  onNavigatorEvent(navigatorDismissEventProps)

  expect(Navigation.dismissAllModals).toHaveBeenCalled()
})

test('modal saving is shown on assignment update', () => {
  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />
  )

  let updateAssignment = jest.fn(() => {
    setProps(component, { pending: true })
  })
  component.update(<AssignmentDetailsEdit {...doneButtonPressedProps} updateAssignment={updateAssignment}/>)

  onNavigatorEvent(navigatorDismissEventProps)

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

  onNavigatorEvent(navigatorDismissEventProps)

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

  onNavigatorEvent(navigatorCancelEventProps)

  expect(Navigation.dismissAllModals).toHaveBeenCalled()
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

  onNavigatorEvent(navigatorDismissEventProps)

  let expected = { ...defaultProps.assignmentDetails, grading_type: selectedValue }
  expect(defaultProps.updateAssignment).toHaveBeenCalledWith(doneButtonPressedProps.courseID, expected, defaultProps.assignmentDetails)
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

describe('editing description', () => {
  beforeEach(() => {
    jest.resetAllMocks()
  })

  it('sends bold action', () => {
    expect(pressAction('bold').toJSON()).toMatchSnapshot()
  })

  it('sends italic action', () => {
    expect(pressAction('italic').toJSON()).toMatchSnapshot()
  })

  it('sends unordered list action', () => {
    expect(pressAction('unorderedList').toJSON()).toMatchSnapshot()
  })

  it('sends ordered list action', () => {
    expect(pressAction('orderedList').toJSON()).toMatchSnapshot()
  })

  it('prompts to insert link', () => {
    expect(pressAction('link').toJSON()).toMatchSnapshot()
  })

  it('shows color picker', () => {
    expect(pressAction('textColor').toJSON()).toMatchSnapshot()
  })

  it('sends action to set text color', () => {
    const component = pressAction('textColor')
    const colorOption: any = explore(component.toJSON()).selectByID('color-picker-option-white')
    colorOption.props.onPress()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('stops editing on done', () => {
    expect(pressAction('done').toJSON()).toMatchSnapshot()
  })

  it('sends undo action', () => {
    expect(pressAction('undo').toJSON()).toMatchSnapshot()
  })

  it('sends redo action', () => {
    expect(pressAction('redo').toJSON()).toMatchSnapshot()
  })

  describe('link modal', () => {
    let component
    let linkModal
    beforeEach(() => {
      component = pressAction('link')

      const titleInput: any = explore(component.toJSON()).selectByID('rich-text-editor.link-modal.titleInput')
      const urlInput: any = explore(component.toJSON()).selectByID('rich-text-editor.link-modal.urlInput')
      const okButton: any = explore(component.toJSON()).selectByID('rich-text-editor.link-modal.okButton')

      linkModal = { titleInput, urlInput, okButton }
    })

    it('inserts new links', () => {
      postMessage(component, 'INSERT_LINK', null)
      linkModal.titleInput.props.onChangeText('test link title')
      linkModal.urlInput.props.onChangeText('test url title')
      linkModal.okButton.props.onPress()

      expect(component.toJSON()).toMatchSnapshot()
    })

    it('inserts link using current selection', () => {
      postMessage(component, 'INSERT_LINK', 'this text is selected')
      linkModal.urlInput.props.onChangeText('http://test-selected-text-link.com')
      linkModal.okButton.props.onPress()
      expect(component.toJSON()).toMatchSnapshot()
    })

    it('updates existing links', () => {
      const link = {
        url: 'http://test-update-link.com',
        title: 'test update link',
      }
      postMessage(component, 'LINK_TOUCHED', link)
      linkModal.okButton.props.onPress()
      expect(component.toJSON()).toMatchSnapshot()
    })
  })

  function pressAction (action: string): any {
    const component = renderer.create(
      <AssignmentDetailsEdit {...defaultProps} />
    )

    const editor: any = explore(component.toJSON()).selectByID('rich-text-editor')
    editor.props.onFocus()

    const item: any = explore(component.toJSON()).selectByID(`rich-text-toolbar-item-${action}`)
    item.props.onPress()

    return component
  }

  function postMessage (component: any, type: string, data: any) {
    const webView: any = explore(component.toJSON()).query(({ type }) => type === 'WebView')[0]
    const message = { type: type, data: data }
    const event = { nativeEvent: { data: JSON.stringify(message) } }
    webView.props.onMessage(event)
  }
})

function testInputField (ref: string, input: any, assignmentField: string) {
  let component = renderer.create(
    <AssignmentDetailsEdit {...doneButtonPressedProps} />
  )

  let tree = component.toJSON()
  let field = explore(tree).selectByID(ref) || {}
  field.props.onChangeText(input)

  onNavigatorEvent(navigatorDismissEventProps)

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

  onNavigatorEvent(navigatorDismissEventProps)

  let expected = { ...defaultProps.assignmentDetails, [assignmentField]: input }
  expect(defaultProps.updateAssignment).toHaveBeenCalledWith(doneButtonPressedProps.courseID, expected, defaultProps.assignmentDetails)
}
