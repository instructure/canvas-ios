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

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import { NativeModules, Clipboard } from 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import RNFS from 'react-native-fs'

import ZSSRichTextEditor from '../ZSSRichTextEditor'
import explore from '../../../../../test/helpers/explore'

import * as template from '../../../../__templates__'

jest
  .mock('ScrollView', () => 'ScrollView')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('Button', () => 'Button')
  .mock('../LinkModal', () => 'LinkModal')
  .mock('WebView', () => 'WebView')
  .mock('react-native-fs', () => ({
    MainBundlePath: 'file:///mainBundle',
    readFile: jest.fn(() => Promise.resolve('<html></html>')),
  }))

describe('ZSSRichTextEditor', () => {
  let js
  beforeEach(() => {
    jest.clearAllMocks()

    js = jest.fn()
  })

  const options = {
    createNodeMock: (element) => {
      if (element.type === 'WebView') {
        return {
          injectJavaScript: js,
        }
      }
    },
  }

  const webView = (component) => {
    return explore(component.toJSON()).query(({ type }) => type === 'WebView')[0]
  }

  it('renders', () => {
    expect(
      renderer.create(
        <ZSSRichTextEditor />
      )
    ).toMatchSnapshot()
  })

  it('uses source from rich text html in main bundle', async () => {
    const pathPromise = Promise.resolve('file:///editor.html')
    NativeModules.NativeFileSystem.pathForResource = jest.fn(() => pathPromise)
    const view = shallow(<ZSSRichTextEditor />)
    await pathPromise
    const html = await RNFS.readFile()
    view.update()
    expect(view.prop('source').html).toEqual(html)
    expect(view.prop('source').baseUrl).toEqual(RNFS.MainBundlePath)
  })

  it('provides unique active editor items', () => {
    const items = jest.fn()
    const component = renderer.create(
      <ZSSRichTextEditor editorItemsChanged={items} />
    )
    const web = webView(component)
    postMessage(web, 'CALLBACK', ['link'])

    expect(items).toHaveBeenCalledWith(['link'])

    postMessage(web, 'CALLBACK', ['link'])
    expect(items).toHaveBeenCalledTimes(1)
  })

  it('gets html', async () => {
    const html = '<p>some html</p>'
    const view = shallow(<ZSSRichTextEditor />)
    const webView = view.find('WebView')
    const getHTML = view.instance().getHTML()
    webView.simulate('Message', { nativeEvent: { data: JSON.stringify({ type: 'EDITOR_HTML', data: html }) } })
    const result = await getHTML
    expect(result).toEqual(html)
  })

  it('notifies when editor focused', () => {
    const onFocus = jest.fn()
    const component = renderer.create(
      <ZSSRichTextEditor onFocus={onFocus} />, options
    )

    const web = webView(component)
    postMessage(web, 'EDITOR_FOCUSED')

    expect(onFocus).toHaveBeenCalled()
    expect(js.mock.calls).toMatchSnapshot()
  })

  it('responds when zss editor loads', () => {
    const component = renderer.create(
      <ZSSRichTextEditor />, options
    )

    const web = webView(component)
    postMessage(web, 'ZSS_LOADED')

    expect(js.mock.calls).toMatchSnapshot()
  })

  it('triggers undo', () => {
    testTrigger((editor) => editor.undo())
  })

  it('triggers redo', () => {
    testTrigger((editor) => editor.redo())
  })

  it('triggers bold', () => {
    testTrigger((editor) => editor.setBold())
  })

  it('triggers italic', () => {
    testTrigger((editor) => editor.setItalic())
  })

  it('triggers setPlaceholder', () => {
    testTrigger((editor) => editor.setPlaceholder('Add text'))
    testTrigger((editor) => editor.setPlaceholder(null))
  })

  it('triggers insertImage', () => {
    testTrigger((editor) => editor.insertImage('https://canvas.instructure.com/files/1/download'))
  })

  it('triggers insertVideoComment', () => {
    testTrigger((editor) => editor.insertVideoComment('1'))
  })

  it('shows link modal', () => {
    const navigator = template.navigator({ show: jest.fn() })
    const component = renderer.create(
      <ZSSRichTextEditor navigator={navigator} />, options
    )
    component.getInstance().insertLink()
    const web = webView(component)
    postMessage(web, 'INSERT_LINK')
    expect(navigator.show).toHaveBeenCalledWith(
      '/rich-text-editor/link',
      {
        modal: true,
        modalPresentationStyle: 'overCurrentContext',
        modalTransitionStyle: 'fade',
        embedInNavigationController: false,
      },
      {
        url: null,
        title: undefined,
        linkUpdated: expect.any(Function),
        linkCreated: expect.any(Function),
        onCancel: expect.any(Function),
      },
    )
  })

  it('shows link modal when link touched', () => {
    const navigator = template.navigator({ show: jest.fn() })
    const link = {
      url: 'http://test-update-link.com',
      title: 'test update link',
    }
    const component = renderer.create(
      <ZSSRichTextEditor navigator={navigator} />, options
    )
    component.getInstance().insertLink()
    const web = webView(component)
    postMessage(web, 'LINK_TOUCHED', link)
    expect(navigator.show).toHaveBeenCalledWith(
      '/rich-text-editor/link',
      {
        modal: true,
        modalPresentationStyle: 'overCurrentContext',
        modalTransitionStyle: 'fade',
        embedInNavigationController: false,
      },
      {
        url: 'http://test-update-link.com',
        title: 'test update link',
        linkUpdated: expect.any(Function),
        linkCreated: expect.any(Function),
        onCancel: expect.any(Function),
      },
    )
  })

  describe('link modal', () => {
    it('triggers insert new link', () => {
      const navigator = template.navigator({
        show: (route, options, props) => {
          props.linkCreated('url', 'title')
        },
      })
      const component = renderer.create(
        <ZSSRichTextEditor navigator={navigator} />, options
      )
      component.getInstance().insertLink()
      postMessage(webView(component), 'INSERT_LINK')

      expect(js.mock.calls).toMatchSnapshot()
    })

    it('triggers insert link with selection', () => {
      const navigator = template.navigator({ show: jest.fn() })
      const component = renderer.create(
        <ZSSRichTextEditor navigator={navigator} />, options
      )
      component.getInstance().insertLink()
      postMessage(webView(component), 'INSERT_LINK', 'selection')
      expect(navigator.show).toHaveBeenCalledWith(
        '/rich-text-editor/link',
        {
          modal: true,
          modalPresentationStyle: 'overCurrentContext',
          modalTransitionStyle: 'fade',
          embedInNavigationController: false,
        },
        {
          url: null,
          title: 'selection',
          linkUpdated: expect.any(Function),
          linkCreated: expect.any(Function),
          onCancel: expect.any(Function),
        },
      )
    })

    it('triggers update link', () => {
      const navigator = template.navigator({
        show: (route, options, props) => {
          props.linkUpdated('url', 'title')
        },
      })
      const component = renderer.create(
        <ZSSRichTextEditor navigator={navigator} />, options
      )
      component.getInstance().insertLink()
      postMessage(webView(component), 'INSERT_LINK')

      expect(js.mock.calls).toMatchSnapshot()
    })
  })

  it('triggers text color', () => {
    testTrigger((editor) => editor.setTextColor('white'))
  })

  it('triggers unordered list', () => {
    testTrigger((editor) => editor.setUnorderedList())
  })

  it('triggers ordered list', () => {
    testTrigger((editor) => editor.setOrderedList())
  })

  it('triggers focus', () => {
    testTrigger((editor) => editor.focusEditor())
  })

  it('triggers blur', () => {
    testTrigger((editor) => editor.blurEditor())
  })

  it('sets custom css on web view loaded', () => {
    const component = renderer.create(
      <ZSSRichTextEditor />, options
    )
    const web = webView(component)
    web.props.onLoad()
    expect(js.mock.calls).toMatchSnapshot()
  })

  it('notifies when editor loaded', async () => {
    const pathPromise = Promise.resolve('/editor-loaded')
    NativeModules.NativeFileSystem.pathForResource = jest.fn(() => pathPromise)
    const onLoad = jest.fn()
    const screen = shallow(<ZSSRichTextEditor onLoad={onLoad} />)
    await pathPromise
    const webView = screen.find('WebView')

    const jsPromise = Promise.resolve()
    webView.getElement().ref({ injectJavaScript: jest.fn(() => jsPromise) })
    expect(onLoad).not.toHaveBeenCalled()
    webView.simulate('Message', { nativeEvent: { data: JSON.stringify({ type: 'ZSS_LOADED' }) } })
    await new Promise((resolve, reject) => process.nextTick(resolve))
    expect(onLoad).toHaveBeenCalled()
  })

  it('notifies when editor blurred', () => {
    const onBlur = jest.fn()
    const component = renderer.create(
      <ZSSRichTextEditor onBlur={onBlur} />
    )
    const web = webView(component)
    postMessage(web, 'EDITOR_BLURRED')
    expect(onBlur).toHaveBeenCalled()
  })

  it('updates html', () => {
    testTrigger((editor) => editor.updateHTML('<div>Hi</div>'))
    testTrigger((editor) => editor.updateHTML(null))
  })

  describe('paste', () => {
    async function paste (clipboard: string) {
      Clipboard.getString = jest.fn(() => Promise.resolve(clipboard))
      const screen = shallow(<ZSSRichTextEditor />)
      const webView = screen.find('WebView')
      webView.getElement().ref({ injectJavaScript: js })
      webView.simulate('Message', { nativeEvent: { data: JSON.stringify({ type: 'EDITOR_PASTE' }) } })
      await new Promise((resolve, reject) => process.nextTick(resolve))
    }

    let js = jest.fn()
    beforeEach(() => {
      js.mockClear()
    })

    it('pastes plain text', async () => {
      await paste('plain text')
      expect(js.mock.calls).toMatchSnapshot()
    })

    it('only pastes if clipboard has a string', async () => {
      await paste(null)
      expect(js).not.toHaveBeenCalled()
    })

    it('will not be tricked by urls with spaces', async () => {
      await paste('https://one.com/files/1/download https://two.com/files/2/download')
      expect(js.mock.calls).toMatchSnapshot()
    })

    it('only matches file download urls', async () => {
      const notAMatch = 'https://one.com/files/1'
      await paste(notAMatch)
      expect(js.mock.calls).toMatchSnapshot()
    })

    it('downloads and embeds image files', async () => {
      const image = template.file({
        mime_class: 'image',
        url: 'https://verified-download-url.jpg',
      })
      const fileURL = 'https://canvas.instructure.com/files/1/download'
      const getFile = jest.fn(() => Promise.resolve({ data: image }))
      Clipboard.getString = jest.fn(() => Promise.resolve(fileURL))
      const screen = shallow(<ZSSRichTextEditor getFile={getFile} />)
      const webView = screen.find('WebView')
      webView.getElement().ref({ injectJavaScript: js })
      webView.simulate('Message', { nativeEvent: { data: JSON.stringify({ type: 'EDITOR_PASTE' }) } })
      await new Promise((resolve, reject) => process.nextTick(resolve))
      expect(js.mock.calls).toMatchSnapshot()
    })

    it('pastes link when file is not an image', async () => {
      const file = template.file({
        mime_class: 'file',
        url: 'https://verified-download-url.jpg',
      })
      const fileURL = 'https://canvas.instructure.com/files/1/download'
      const getFile = jest.fn(() => Promise.resolve({ data: file }))
      Clipboard.getString = jest.fn(() => Promise.resolve(fileURL))
      const screen = shallow(<ZSSRichTextEditor getFile={getFile} />)
      const webView = screen.find('WebView')
      webView.getElement().ref({ injectJavaScript: js })
      webView.simulate('Message', { nativeEvent: { data: JSON.stringify({ type: 'EDITOR_PASTE' }) } })
      await new Promise((resolve, reject) => process.nextTick(resolve))
      expect(js.mock.calls).toMatchSnapshot()
    })

    it('catches error and pastes clipboard if network call fails', () => {
      expect(async () => {
        const fileURL = 'https://canvas.instructure.com/files/1/download'
        const getFile = jest.fn(() => Promise.reject('ERROR'))
        Clipboard.getString = jest.fn(() => Promise.resolve(fileURL))
        const screen = shallow(<ZSSRichTextEditor getFile={getFile} />)
        const webView = screen.find('WebView')
        webView.getElement().ref({ injectJavaScript: js })
        webView.simulate('Message', { nativeEvent: { data: JSON.stringify({ type: 'EDITOR_PASTE' }) } })
        await new Promise((resolve, reject) => process.nextTick(resolve))
        expect(js.mock.calls).toMatchSnapshot()
      }).not.toThrow()
    })
  })

  function testTrigger (trigger: (editor: any) => void) {
    const screen = shallow(<ZSSRichTextEditor />)
    screen.find('WebView').getElement().ref({ injectJavaScript: js })
    trigger(screen.instance())
    expect(js.mock.calls).toMatchSnapshot()
  }

  function postMessage (webView: any, type: string, data: any) {
    const message = { type, data }
    const event = { nativeEvent: { data: JSON.stringify(message) } }
    webView.props.onMessage(event)
  }
})
