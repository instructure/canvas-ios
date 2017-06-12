/* @flow */

import { NativeModules } from 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import RichTextEditor, { type Props } from '../RichTextEditor'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('WebView', () => 'WebView')
  .mock('ScrollView', () => 'ScrollView')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('Button', () => 'Button')
  .mock('../ZSSRichTextEditor')
  .mock('../RichTextToolbar')
  .mock('react-native-keyboard-spacer', () => 'KeyboardSpacer')

describe('RichTextEditor', () => {
  let props: Props
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

  it('sets editor content height on load', () => {
    props.contentHeight = 200
    const mock = jest.fn()
    const component = render(props)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props._setMock('setContentHeight', mock)
    editor.props.onLoad()
    expect(mock).toHaveBeenCalledWith(200)
  })

  it('can be keyboard aware', () => {
    props.keyboardAware = true
    const component = render(props)
    expect(explore(component.toJSON()).query(({ type }) => type === 'KeyboardSpacer')).toHaveLength(1)
  })

  it('can ignore keyboard', () => {
    props.keyboardAware = false
    const component = render(props)
    expect(explore(component.toJSON()).query(({ type }) => type === 'KeyboardSpacer')).toHaveLength(0)
  })

  it('can disable scroll', () => {
    props.scrollEnabled = false
    const component = render(props)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    expect(editor.props.scrollEnabled).toBeFalsy()
  })

  it('does height stuff when color picker shown', () => {
    props.contentHeight = 200
    props.showToolbar = 'always'
    const triggerMock = jest.fn()
    const setContentHeightMock = jest.fn()
    const component = render(props)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props._setMock('setContentHeight', setContentHeightMock)
    editor.props._setMock('trigger', triggerMock)
    const toolbar: any = explore(component.toJSON()).query(({ type }) => type === 'RichTextToolbar')[0]
    toolbar.props.onColorPickerShown(true)
    expect(triggerMock.mock.calls[0][0]).toMatchSnapshot()
    expect(setContentHeightMock).toHaveBeenCalledWith(154)
  })

  it('does height stuff when color picker hidden', () => {
    props.contentHeight = 200
    props.showToolbar = 'always'
    const setContentHeightMock = jest.fn()
    const component = render(props)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props._setMock('setContentHeight', setContentHeightMock)
    const toolbar: any = explore(component.toJSON()).query(({ type }) => type === 'RichTextToolbar')[0]
    toolbar.props.onColorPickerShown(false)
    expect(setContentHeightMock).toHaveBeenCalledWith(200)
  })

  it('sets placeholder on load', () => {
    const mock = jest.fn()
    props.placeholder = 'This is a placeholder'
    const component = render(props)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props._setMock('setPlaceholder', mock)
    editor.props.onLoad()
    expect(mock).toHaveBeenCalledWith('This is a placeholder')
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
