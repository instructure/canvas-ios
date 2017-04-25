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
  .mock('../../../common/components/rich-text-editor/RichTextEditor')

const template = {
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../__templates__/react-native-navigation'),
}

describe('AssignmentDescription', () => {
  const defaultProps = {
    navigator: template.navigator(),
    description: '<p>This is a description</p>',
  }

  beforeEach(() => {
    jest.resetAllMocks()

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
    const editor: any = explore(tree).selectByID('rich-text-editor')

    editor.props.onLoad()

    expect(NativeModules.WebViewHacker.removeInputAccessoryView).toHaveBeenCalled()
    expect(NativeModules.WebViewHacker.setKeyboardDisplayRequiresUserAction).toHaveBeenCalledWith(false)
  })
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
