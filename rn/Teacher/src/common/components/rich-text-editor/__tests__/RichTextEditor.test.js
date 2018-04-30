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

import { shallow } from 'enzyme'
import React from 'react'
import RichTextEditor, { type Props } from '../RichTextEditor'
import * as template from '../../../../__templates__'

describe('RichTextEditor', () => {
  let props: Props
  beforeEach(() => {
    props = {
      defaultValue: '',
      navigator: template.navigator(),
      attachmentUploadPath: null,
    }
  })

  const measureInWindow = jest.fn((fn) => {
    fn(0, 0, 2436, 1125)
  })

  it('renders', () => {
    const tree = shallow(<RichTextEditor {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders toolbar when editor focused', () => {
    const tree = shallow(<RichTextEditor {...props} />)
    tree.getElement().ref({ measureInWindow })
    tree.simulate('Layout')
    tree.find('ZSSRichTextEditor').simulate('Load')
    tree.find('ZSSRichTextEditor').simulate('Focus')
    expect(tree).toMatchSnapshot()
  })

  it('hides toolbar when editor blurs', () => {
    const tree = shallow(<RichTextEditor {...props} />)
    tree.getElement().ref({ measureInWindow })
    const editor = tree.find('ZSSRichTextEditor')
    editor.simulate('Focus')
    editor.simulate('Blur')
    expect(tree).toMatchSnapshot()
  })

  it('hides toolbar when showToolbar is false', () => {
    props.showToolbar = 'never'
    const tree = shallow(<RichTextEditor {...props} />)
    tree.find('ZSSRichTextEditor').simulate('Load')
    expect(tree).toMatchSnapshot()
  })

  it('gets html', async () => {
    const tree = shallow(<RichTextEditor {...props} />)
    tree.find('ZSSRichTextEditor').getElement().ref({
      getHTML: jest.fn(() => Promise.resolve('<p>Hi there!</p>')),
    })
    const result = await tree.instance().getHTML()
    expect(result).toEqual('<p>Hi there!</p>')
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
      const image = template.attachment({
        url: 'https://canvas.instructure.com/files/1/download',
        mime_class: 'image',
      })
      props.navigator = template.navigator({
        show: jest.fn((route, options, props) => {
          props.onComplete([image])
        }),
      })

      const mock = jest.fn()
      const tree = shallow(<RichTextEditor {...props} />)
      tree.getElement().ref({ measureInWindow })
      const editor = tree.find('ZSSRichTextEditor')
      editor.simulate('Load')
      editor.simulate('Focus')
      editor.getElement().ref({
        insertImage: mock,
        prepareInsert: jest.fn(),
        insertVideoComment: jest.fn(),
      })
      const toolbar = tree.find('RichTextToolbar')
      toolbar.props().insertImage()
      expect(mock).toHaveBeenLastCalledWith(image.url)
    })

    it('should insert video comment', () => {
      props.attachmentUploadPath = '/users/self/files'
      const video = template.attachment({
        media_entry_id: '1',
        uri: 'file:///path/to/video.mov',
        mime_class: 'video',
      })
      props.navigator = template.navigator({
        show: jest.fn((route, options, props) => {
          props.onComplete([video])
        }),
      })

      const mock = jest.fn()
      const tree = shallow(<RichTextEditor {...props} />)
      tree.getElement().ref({ measureInWindow })
      const editor = tree.find('ZSSRichTextEditor')
      editor.simulate('Load')
      editor.simulate('Focus')
      editor.getElement().ref({
        insertImage: jest.fn(),
        prepareInsert: jest.fn(),
        insertVideoComment: mock,
      })
      const toolbar = tree.find('RichTextToolbar')
      toolbar.props().insertImage()
      expect(mock).toHaveBeenCalledWith(video.media_entry_id)
    })
  })

  it('should update active editor items in toolbar', () => {
    const tree = shallow(<RichTextEditor {...props} />)
    tree.getElement().ref({ measureInWindow })
    const editor = tree.find('ZSSRichTextEditor')
    editor.simulate('Focus')
    editor.simulate('Load')
    editor.props().editorItemsChanged(['italic'])
    expect(tree).toMatchSnapshot()
    editor.props().editorItemsChanged(['bold'])
    expect(tree).toMatchSnapshot()
  })

  it('sets editor content height on load', () => {
    props.contentHeight = 200
    const mock = jest.fn()
    const tree = shallow(<RichTextEditor {...props} />)
    tree.getElement().ref({ measureInWindow })
    const editor = tree.find('ZSSRichTextEditor')
    editor.getElement().ref({ setContentHeight: mock })
    editor.simulate('Load')
    expect(mock).toHaveBeenCalledWith(200)
  })

  it('sets html on load', () => {
    props.defaultValue = '<p>Hello world</p>'
    const mock = jest.fn()
    const tree = shallow(<RichTextEditor {...props} />)
    const editor = tree.find('ZSSRichTextEditor')
    editor.getElement().ref({ updateHTML: mock })
    editor.simulate('Load')
    expect(mock).toHaveBeenCalledWith(props.defaultValue)
  })

  it('sets html when defaultValue changes', () => {
    props.defaultValue = null
    const mock = jest.fn()
    const tree = shallow(<RichTextEditor {...props} />)
    const editor = tree.find('ZSSRichTextEditor')
    editor.getElement().ref({ updateHTML: mock })
    tree.setProps({ defaultValue: '<p>New default</p>' })
    tree.setProps({ defaultValue: '<p>New default</p>' })
    expect(mock).toHaveBeenCalledWith('<p>New default</p>')
    expect(mock).toHaveBeenCalledTimes(1)
  })

  it('can be keyboard aware', () => {
    props.keyboardAware = true
    const tree = shallow(<RichTextEditor {...props} />)
    tree.getElement().ref({ measureInWindow })
    expect(tree.find('KeyboardSpacer')).toHaveLength(1)
    tree.find('KeyboardSpacer').simulate('Toggle')
    expect(tree).toMatchSnapshot()
  })

  it('can ignore keyboard', () => {
    props.keyboardAware = false
    const tree = shallow(<RichTextEditor {...props} />)
    expect(tree.find('KeyboardSpacer')).toHaveLength(0)
  })

  it('can disable scroll', () => {
    props.scrollEnabled = false
    const tree = shallow(<RichTextEditor {...props} />)
    const editor = tree.find('ZSSRichTextEditor')
    expect(editor.props.scrollEnabled).toBeFalsy()
  })

  it('does height stuff when color picker shown', () => {
    props.contentHeight = 200
    props.showToolbar = 'always'
    const triggerMock = jest.fn()
    const setContentHeightMock = jest.fn()
    const tree = shallow(<RichTextEditor {...props} />)
    const editor = tree.find('ZSSRichTextEditor')
    editor.getElement().ref({
      setContentHeight: setContentHeightMock,
      trigger: triggerMock,
    })
    editor.simulate('Load')
    tree.find('RichTextToolbar').simulate('ColorPickerShown', true)
    expect(triggerMock.mock.calls[0][0]).toMatchSnapshot()
    expect(setContentHeightMock).toHaveBeenCalledWith(154)
  })

  it('does height stuff when color picker hidden', () => {
    props.contentHeight = 200
    props.showToolbar = 'always'
    const setContentHeightMock = jest.fn()
    const tree = shallow(<RichTextEditor {...props} />)
    const editor = tree.find('ZSSRichTextEditor')
    editor.getElement().ref({ setContentHeight: setContentHeightMock })
    editor.simulate('Load')
    tree.find('RichTextToolbar').simulate('ColorPickerShown', false)
    expect(setContentHeightMock).toHaveBeenCalledWith(200)
  })

  it('ignores height stuff when no contentHeight', () => {
    props.contentHeight = undefined
    props.showToolbar = 'always'
    const setContentHeightMock = jest.fn()
    const tree = shallow(<RichTextEditor {...props} />)
    const editor = tree.find('ZSSRichTextEditor')
    editor.getElement().ref({ setContentHeight: setContentHeightMock })
    editor.simulate('Load')
    tree.find('RichTextToolbar').simulate('ColorPickerShown', false)
    expect(setContentHeightMock).not.toHaveBeenCalled()
  })

  it('sets placeholder on load', () => {
    const mock = jest.fn()
    props.placeholder = 'This is a placeholder'
    const tree = shallow(<RichTextEditor {...props} />)
    const editor = tree.find('ZSSRichTextEditor')
    editor.getElement().ref({ setPlaceholder: mock })
    editor.simulate('Load')
    expect(mock).toHaveBeenCalledWith('This is a placeholder')
  })

  it('shows keyboard on load with focus prop', () => {
    let focusProps = {
      ...props,
      focusOnLoad: true,
    }
    const mock = jest.fn()
    const tree = shallow(<RichTextEditor {...focusProps} />)
    tree.find('ZSSRichTextEditor').getElement().ref({ focusEditor: mock })
    tree.find('ZSSRichTextEditor').simulate('Load')
    expect(mock).toHaveBeenCalled()
  })

  it('calls onFocus prop when focus is received', () => {
    const mock = jest.fn()
    let focusProps = {
      ...props,
      onFocus: mock,
    }

    const tree = shallow(<RichTextEditor {...focusProps} />)
    tree.getElement().ref({ measureInWindow })
    const editor = tree.find('ZSSRichTextEditor')
    editor.simulate('Focus')
    expect(mock).toHaveBeenCalled()
  })

  function testToolbarAction (action: string) {
    const mock = jest.fn()
    const tree = shallow(<RichTextEditor {...props} />)
    tree.getElement().ref({ measureInWindow })
    tree.find('ZSSRichTextEditor').simulate('Load')
    tree.find('ZSSRichTextEditor').simulate('Focus')
    tree.find('ZSSRichTextEditor').getElement().ref({
      [action]: mock,
      prepareInsert: jest.fn(),
    })
    tree.find('RichTextToolbar').prop(action)()
    expect(mock).toHaveBeenCalled()
  }
})
