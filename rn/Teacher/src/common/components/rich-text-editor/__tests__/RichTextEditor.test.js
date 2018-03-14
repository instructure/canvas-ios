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

/* @flow */

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import RichTextEditor, { type Props } from '../RichTextEditor'
import explore from '../../../../../test/helpers/explore'
import Navigator from '../../../../routing/Navigator'
import { attachment } from '../../../../__templates__/attachment'
import { navigator } from '../../../../__templates__/helm'
import setProps from '../../../../../test/helpers/setProps'

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
      navigator: new Navigator(''),
      attachmentUploadPath: null,
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders toolbar when editor focused', () => {
    const component = render(props)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props.onLoad()
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

    it('should insert image', () => {
      props.attachmentUploadPath = '/users/self/files'
      const image = attachment({
        url: 'https://canvas.instructure.com/files/1/download',
        mime_class: 'image',
      })
      props.navigator = navigator({
        show: jest.fn((route, options, props) => {
          props.onComplete([image])
        }),
      })

      const mock = jest.fn()
      const component = render(props)
      const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
      editor.props.onLoad()
      editor.props.onFocus()
      editor.props._setMock('insertImage', mock)
      editor.props._setMock('prepareInsert', jest.fn())
      editor.props._setMock('insertVideoComment', jest.fn())
      const toolbar: any = explore(component.toJSON()).query(({ type }) => type === 'RichTextToolbar')[0]
      toolbar.props.insertImage()
      expect(mock).toHaveBeenLastCalledWith(image.url)
    })

    it('should insert video comment', () => {
      props.attachmentUploadPath = '/users/self/files'
      const video = attachment({
        mediaID: '1',
        uri: 'file:///path/to/video.mov',
        mime_class: 'video',
      })
      props.navigator = navigator({
        show: jest.fn((route, options, props) => {
          props.onComplete([video])
        }),
      })

      const mock = jest.fn()
      const component = render(props)
      const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
      editor.props.onLoad()
      editor.props.onFocus()
      editor.props._setMock('insertVideoComment', mock)
      editor.props._setMock('prepareInsert', jest.fn())
      editor.props._setMock('insertImage', jest.fn())
      const toolbar: any = explore(component.toJSON()).query(({ type }) => type === 'RichTextToolbar')[0]
      toolbar.props.insertImage()
      expect(mock).toHaveBeenCalledWith(video.uri, video.mediaID)
    })
  })

  it('should update active editor items in toolbar', () => {
    const component = render(props)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props.onFocus()
    editor.props.onLoad()
    editor.props.editorItemsChanged(['italic'])
    expect(component.toJSON()).toMatchSnapshot()
    editor.props.editorItemsChanged(['bold'])
    expect(component.toJSON()).toMatchSnapshot()
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

  it('sets html on load', () => {
    props.defaultValue = '<p>Hello world</p>'
    const mock = jest.fn()
    const component = render(props)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props._setMock('updateHTML', mock)
    editor.props.onLoad()
    expect(mock).toHaveBeenCalledWith(props.defaultValue)
  })

  it('sets html when defaultValue changes', () => {
    props.defaultValue = null
    const mock = jest.fn()
    const component = render(props)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props._setMock('updateHTML', mock)
    setProps(component, { defaultValue: '<p>New default</p>' })
    setProps(component, { defaultValue: '<p>New default</p>' })
    expect(mock).toHaveBeenCalledWith('<p>New default</p>')
    expect(mock).toHaveBeenCalledTimes(1)
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
    editor.props.onLoad()
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
    editor.props.onLoad()
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

  it('shows keyboard on load with focus prop', () => {
    let focusProps = {
      ...props,
      focusOnLoad: true,
    }
    const mock = jest.fn()
    const component = render(focusProps)
    const editor: any = explore(component.toJSON()).query(({ type }) => type === 'ZSSRichTextEditor')[0]
    editor.props._setMock('focusEditor', mock)
    editor.props.onLoad()
    expect(mock).toHaveBeenCalled()
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
    editor.props.onLoad()
    editor.props.onFocus()
    editor.props._setMock(action, mock)
    editor.props._setMock('prepareInsert', jest.fn())
    const toolbar: any = explore(component.toJSON()).query(({ type }) => type === 'RichTextToolbar')[0]
    toolbar.props[action]()
    expect(mock).toHaveBeenCalled()
  }
})
