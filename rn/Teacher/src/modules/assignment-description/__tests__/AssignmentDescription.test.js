/* @flow */

import {
  NativeModules,
} from 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import { AssignmentDescription, mapStateToProps } from '../AssignmentDescription'
import explore from '../../../../test/helpers/explore'

jest
  .mock('WebView', () => 'WebView')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('Button', () => 'Button')
  .mock('../../../common/components/rich-text-editor/RichTextEditor', () => 'RichTextEditor')
  .mock('../../../common/components/rich-text-editor/RichTextToolbar', () => 'RichTextToolbar')

const template = {
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../__templates__/helm'),
}

describe('AssignmentDescription', () => {
  let defaultProps
  beforeEach(() => {
    jest.resetAllMocks()

    defaultProps = {
      navigator: template.navigator(),
      description: '<p>This is a description</p>',
      assignmentID: '1',
    }

    NativeModules.WebViewHacker = {
      removeInputAccessoryView: jest.fn(),
      setKeyboardDisplayRequiresUserAction: jest.fn(),
    }
  })

  it('renders', () => {
    expect(
      renderer.create(
        <AssignmentDescription {...defaultProps} />
      ).toJSON()
    ).toMatchSnapshot()
  })

  it('hacks the webview on load', () => {
    const tree = renderer.create(
      <AssignmentDescription {...defaultProps} />
    ).toJSON()
    const editor: any = explore(tree).query(({ type }) => type === 'RichTextEditor')[0]

    editor.props.onLoad()

    expect(NativeModules.WebViewHacker.removeInputAccessoryView).toHaveBeenCalled()
    expect(NativeModules.WebViewHacker.setKeyboardDisplayRequiresUserAction).toHaveBeenCalledWith(false)
  })

  it('updates assignment description on unmount', () => {
    const props = {
      ...defaultProps,
      assignmentID: '47',
      description: 'unmount update',
      updateAssignmentDescription: jest.fn(),
    }
    const component = renderer.create(
      <AssignmentDescription {...props} />
    )

    component.getInstance().componentWillUnmount()

    expect(props.updateAssignmentDescription).toHaveBeenCalledWith('47', 'unmount update')
  })

  it('sets bold', () => {
    testToolbarAction('setBold')
  })

  it('sets italic', () => {
    testToolbarAction('setItalic')
  })

  it('sets unordered list', () => {
    testToolbarAction('setUnorderedList')
  })

  it('sets ordered list', () => {
    testToolbarAction('setOrderedList')
  })

  it('inserts link', () => {
    testToolbarAction('insertLink')
  })

  it('sets text color', () => {
    testToolbarAction('setTextColor')
  })

  it('triggers undo', () => {
    testToolbarAction('undo')
  })

  it('triggers redo', () => {
    testToolbarAction('redo')
  })

  function testToolbarAction (action: string) {
    const mockAction = jest.fn()
    const options = {
      createNodeMock: (element) => {
        if (element.type === 'RichTextEditor') {
          return {
            [action]: mockAction,
          }
        }
      },
    }
    const component = renderer.create(
      <AssignmentDescription {...defaultProps} />, options
    )
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'RichTextEditor')[0]
    editor.props.onFocus()
    const toolbar: any = explore(component.toJSON()).query(({ type }) => type === 'RichTextToolbar')[0]
    toolbar.props[action]()
    expect(mockAction).toHaveBeenCalled()
  }
})

describe('map state to props', () => {
  it('maps state to props', () => {
    const description = 'map state to props description'
    const assignment = template.assignment({ description })

    const state = template.appState({
      entities: {
        assignments: {
          [assignment.id]: { data: assignment, pending: 0 },
        },
      },
    })

    const ownProps = {
      courseID: '1',
      assignmentID: assignment.id,
    }

    const result = mapStateToProps(state, ownProps)
    expect(result).toEqual({
      id: assignment.id,
      description,
    })
  })

  it('maps empty state to empty props', () => {
    const emptyState = template.appState({
      entities: {},
    })
    const ownProps = {
      courseID: '1',
      assignmentID: '1',
    }
    expect(
      mapStateToProps(emptyState, ownProps)
    ).toEqual({ id: '1', description: null })
  })
})
