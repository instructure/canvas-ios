/* @flow */

import { NativeModules } from 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import RichTextEditor from '../RichTextEditor'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('WebView', () => 'WebView')
  .mock('ScrollView', () => 'ScrollView')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('Button', () => 'Button')
  .mock('../ZSSRichTextEditor')
  .mock('../RichTextToolbar')

describe('RichTextEditor', () => {
  let props
  beforeEach(() => {
    props = {
      onChangeValue: jest.fn(),
      defaultValue: '',
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders toolbar when editor focused', () => {
    const component = render(props)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props.onFocus()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('hides toolbar when editor blurs', () => {
    const component = render(props)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props.onFocus()
    editor.props.onBlur()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('notifies when editor value changes', () => {
    props.onChangeValue = jest.fn()
    const tree = render(props).toJSON()
    const editor: any = explore(tree).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props.onInputChange('text!')
    expect(props.onChangeValue).toHaveBeenCalledWith('text!')
  })

  describe('toolbar actions', () => {
    it('should set bold', () => {
      testToolbarAction('setBold')
    })

    it('should set italic', () => {
      testToolbarAction('setItalic')
    })

    it('should set unorderd list', () => {
      testToolbarAction('setUnorderedList')
    })

    it('should set orderd list', () => {
      testToolbarAction('setOrderedList')
    })

    it('should insert link', () => {
      testToolbarAction('insertLink')
    })

    it('should set text color', () => {
      testToolbarAction('setTextColor')
    })

    it('should set undo', () => {
      testToolbarAction('undo')
    })

    it('should set redo', () => {
      testToolbarAction('redo')
    })
  })

  it('should update active editor items in toolbar', () => {
    const component = render(props)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props.onFocus()
    editor.props.editorItemsChanged(['italic'])
    expect(component.toJSON()).toMatchSnapshot()
    editor.props.editorItemsChanged(['bold'])
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('hacks the webview on load', () => {
    NativeModules.WebViewHacker = {
      removeInputAccessoryView: jest.fn(),
      setKeyboardDisplayRequiresUserAction: jest.fn(),
    }
    const component = render(props)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props.onLoad()
    expect(NativeModules.WebViewHacker.removeInputAccessoryView).toHaveBeenCalled()
    expect(NativeModules.WebViewHacker.setKeyboardDisplayRequiresUserAction).toHaveBeenCalledWith(false)
  })

  function render (props): any {
    return renderer.create(<RichTextEditor {...props} />)
  }

  function testRender (props) {
    expect(render(props)).toMatchSnapshot()
  }

  function testToolbarAction (action: string) {
    const mock = jest.fn()
    const component = render(props)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props.onFocus()
    editor.props._setMock(action, mock)
    const toolbar: any = explore(component.toJSON()).query(({ type }) => type === 'RichTextToolbar')[0]
    toolbar.props[action]()
    expect(mock).toHaveBeenCalled()
  }
})
