//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import { NativeModules, Clipboard, I18nManager } from 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import ZSSRichTextEditor from '../ZSSRichTextEditor'
import explore from '../../../../../test/helpers/explore'

import * as template from '../../../../__templates__'

jest
  .mock('react-native/Libraries/Components/ScrollView/ScrollView', () => 'ScrollView')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Button', () => 'Button')
  .mock('../LinkModal', () => 'LinkModal')
  .mock('../../CanvasWebView', () => 'CanvasWebView')
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
      if (element.type === 'CanvasWebView') {
        return {
          evaluateJavaScript: js,
        }
      }
    },
  }

  const webView = (component) => {
    return explore(component.toJSON()).query(({ type }) => type === 'CanvasWebView')[0]
  }

  it('renders', () => {
    expect(
      renderer.create(
        <ZSSRichTextEditor />
      )
    ).toMatchSnapshot()
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
    const webView = view.find('CanvasWebView')
    const getHTML = view.instance().getHTML()
    webView.simulate('Message', { body: JSON.stringify({ type: 'EDITOR_HTML', data: html }) })
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

  it('loads with rtl direction when in rtl', () => {
    I18nManager.isRTL = true
    const component = renderer.create(
      <ZSSRichTextEditor />, options
    )

    const web = webView(component)
    postMessage(web, 'ZSS_LOADED')

    expect(js.mock.calls).toMatchSnapshot()
    I18nManager.isRTL = false
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

  it('notifies when editor loaded', async () => {
    const pathPromise = Promise.resolve('/editor-loaded')
    NativeModules.NativeFileSystem.pathForResource = jest.fn(() => pathPromise)
    const onLoad = jest.fn()
    const screen = shallow(<ZSSRichTextEditor onLoad={onLoad} />)
    await pathPromise
    const webView = screen.find('CanvasWebView')

    const jsPromise = Promise.resolve()
    webView.getElement().ref({ evaluateJavaScript: jest.fn(() => jsPromise) })
    expect(onLoad).not.toHaveBeenCalled()
    webView.simulate('Message', { body: JSON.stringify({ type: 'ZSS_LOADED' }) })
    await new Promise((resolve, reject) => process.nextTick(resolve))
    expect(onLoad).toHaveBeenCalled()
  })

  it('sets feature flags', async () => {
    const screen = shallow(<ZSSRichTextEditor />)
    const webView = screen.find('CanvasWebView')

    let js = jest.fn()
    webView.getElement().ref({ evaluateJavaScript: js })
    screen.instance().setFeatureFlags(['one', 'two'])
    expect(js.mock.calls).toMatchSnapshot()
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
      const webView = screen.find('CanvasWebView')
      webView.getElement().ref({ evaluateJavaScript: js })
      webView.simulate('Message', { body: JSON.stringify({ type: 'EDITOR_PASTE' }) })
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

    it('replaces newlines with <br>', async () => {
      await paste('Line One\nLine Two')
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
      const webView = screen.find('CanvasWebView')
      webView.getElement().ref({ evaluateJavaScript: js, setFeatureFlags: jest.fn() })
      webView.simulate('Message', { body: JSON.stringify({ type: 'EDITOR_PASTE' }) })
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
      const webView = screen.find('CanvasWebView')
      webView.getElement().ref({ evaluateJavaScript: js, setFeatureFlags: jest.fn() })
      webView.simulate('Message', { body: JSON.stringify({ type: 'EDITOR_PASTE' }) })
      await new Promise((resolve, reject) => process.nextTick(resolve))
      expect(js.mock.calls).toMatchSnapshot()
    })

    it('catches error and pastes clipboard if network call fails', () => {
      expect(async () => {
        const fileURL = 'https://canvas.instructure.com/files/1/download'
        const getFile = jest.fn(() => Promise.reject('ERROR'))
        Clipboard.getString = jest.fn(() => Promise.resolve(fileURL))
        const screen = shallow(<ZSSRichTextEditor getFile={getFile} />)
        const webView = screen.find('CanvasWebView')
        webView.getElement().ref({ evaluateJavaScript: js })
        webView.simulate('Message', { body: JSON.stringify({ type: 'EDITOR_PASTE' }) })
        await new Promise((resolve, reject) => process.nextTick(resolve))
        expect(js.mock.calls).toMatchSnapshot()
      }).not.toThrow()
    })
  })

  function testTrigger (trigger: (editor: any) => void) {
    const screen = shallow(<ZSSRichTextEditor />)
    screen.find('CanvasWebView').getElement().ref({ evaluateJavaScript: js, setFeatureFlags: jest.fn() })
    trigger(screen.instance())
    expect(js.mock.calls).toMatchSnapshot()
  }

  function postMessage (webView: any, type: string, data: any) {
    const message = { type, data }
    const event = { body: JSON.stringify(message) }
    webView.props.onMessage(event)
  }
})
