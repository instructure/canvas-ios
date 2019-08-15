//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import React from 'react'
import { NativeModules } from 'react-native'
import { shallow } from 'enzyme'
import CanvasWebView, { type Props, heightCache } from '../CanvasWebView'
import { setSession } from '../../../canvas-api/session'

const template = {
  ...require('../../../__templates__/helm'),
  ...require('../../../__templates__/session'),
}

describe('CanvasWebView', () => {
  let props: Props

  beforeEach(() => {
    jest.clearAllMocks()

    props = {
      scrollEnabled: true,
      navigator: template.navigator(),
    }
  })

  it('renders html', () => {
    const html = '<div>Hello, World!</div>'
    const baseURL = 'https://narmstrong.instructure.com'
    setSession(template.session({ baseURL }))
    const tree = shallow(<CanvasWebView {...props} html={html} />)
    const webView = tree.find('WebView')
    expect(webView.props().source).toEqual({ html, baseURL })
  })

  it('renders uri', () => {
    const uri = 'https://apple.com'
    const tree = shallow(<CanvasWebView {...props} source={{ uri }} />)
    const webView = tree.find('WebView')
    expect(webView.props().source).toEqual({ uri })
  })

  it('sends messages', () => {
    const onMessage = jest.fn()
    const tree = shallow(<CanvasWebView {...props} onMessage={onMessage} />)
    const webView = tree.find('WebView')
    webView.simulate('Message', { nativeEvent: 'hello' })
    expect(onMessage).toHaveBeenCalledWith('hello')
  })

  it('notifies when finished loading', () => {
    const onFinishedLoading = jest.fn()
    const tree = shallow(<CanvasWebView {...props} onFinishedLoading={onFinishedLoading} />)
    const webView = tree.find('WebView')
    webView.simulate('FinishedLoading')
    expect(onFinishedLoading).toHaveBeenCalled()
  })

  it('handles navigation', () => {
    const navigator = template.navigator({ show: jest.fn() })
    const tree = shallow(<CanvasWebView {...props} navigator={navigator} />)
    const webView = tree.find('WebView')
    const url = 'https://canvas.instructure.com/courses/1/assignments/1'
    webView.simulate('Navigation', { nativeEvent: { url } })
    expect(navigator.show).toHaveBeenCalledWith(url, {
      deepLink: true,
    })
  })

  it('handles navigation when openLinksInSafari is provided', async () => {
    const navigator = template.navigator({ show: jest.fn() })
    const tree = shallow(<CanvasWebView {...props} navigator={navigator} openLinksInSafari />)
    const webView = tree.find('WebView')
    const url = 'https://canvas.instructure.com/courses/1/assignments/1'
    webView.simulate('Navigation', { nativeEvent: { url } })
    expect(navigator.showWebView).toHaveBeenCalledWith(url)
  })

  it('handles navigation callback', () => {
    const navigator = template.navigator({ show: jest.fn() })
    const onNavigation = jest.fn()
    const tree = shallow(<CanvasWebView {...props} navigator={navigator} onNavigation={onNavigation} />)
    const webView = tree.find('WebView')
    const url = 'https://canvas.instructure.com/courses/1/assignments/1'
    webView.simulate('Navigation', { nativeEvent: { url } })
    expect(navigator.show).not.toHaveBeenCalled()
    expect(onNavigation).toHaveBeenCalledWith(url)
  })

  it('sends errors', () => {
    const onError = jest.fn()
    const tree = shallow(<CanvasWebView {...props} onError={onError} />)
    const webView = tree.find('WebView')
    webView.simulate('Error', 'error')
    expect(onError).toHaveBeenCalledWith('error')
  })

  it('evaluates javascript', () => {
    const js = `console.log('Hello, World!');`
    const tree = shallow(<CanvasWebView {...props} />)
    tree.instance().evaluateJavaScript(js)
    expect(NativeModules.CanvasWebViewManager.evaluateJavaScript).toHaveBeenCalledWith(
      null,
      js,
    )
  })

  it('stops refreshing', () => {
    const tree = shallow(<CanvasWebView {...props} />)
    tree.instance().stopRefreshing()
    expect(NativeModules.CanvasWebViewManager.stopRefreshing).toHaveBeenCalled()
  })

  it('updates height to fit content if scroll disabled', async () => {
    const height = 42
    const tree = shallow(<CanvasWebView {...props} scrollEnabled={false} />)
    const webView = tree.find('WebView')
    webView.simulate('HeightChange', { nativeEvent: { height } })
    tree.update()
    expect(tree.find('WebView').props().style.height).toEqual(42)
  })

  it('updates height to fit content if automaticallySetHeight', async () => {
    const height = 42
    const tree = shallow(<CanvasWebView {...props} scrollEnabled={true} automaticallySetHeight />)
    const webView = tree.find('WebView')
    webView.simulate('HeightChange', { nativeEvent: { height } })
    tree.update()
    expect(tree.find('WebView').props().style.height).toEqual(42)
  })

  it('does not update height to fit content if scroll enabled', async () => {
    const height = 42
    const tree = shallow(<CanvasWebView {...props} scrollEnabled={true} />)
    const webView = tree.find('WebView')
    webView.simulate('HeightChange', { nativeEvent: { height } })
    tree.update()
    expect(tree.find('WebView').props().style.height).not.toEqual(42)
  })

  it('caches the height if a heightCacheKey is provided', async () => {
    const height = 42
    const tree = shallow(<CanvasWebView {...props} scrollEnabled={false} heightCacheKey='1' />)
    const webView = tree.find('WebView')
    webView.simulate('HeightChange', { nativeEvent: { height } })
    tree.update()
    expect(heightCache.get('1')).toEqual(42)
  })

  it('sets the height if the height cache already has the height', () => {
    heightCache.set('2', 52)
    const tree = shallow(<CanvasWebView {...props} scrollEnabled={false} heightCacheKey='2' />)
    expect(tree.find('WebView').props().style.height).toEqual(52)
  })

  it('prevents bounce if scroll is disabled', () => {
    props.scrollEnabled = false
    const tree = shallow(<CanvasWebView {...props} />)
    const webView = tree.find('WebView')
    expect(webView.prop('bounces')).toEqual(false)
  })

  it('prevents bounce if height is auto set', () => {
    props.automaticallySetHeight = true
    const tree = shallow(<CanvasWebView {...props} />)
    const webView = tree.find('WebView')
    expect(webView.prop('bounces')).toEqual(false)
  })

  it('bounces if scroll enabled and height is not auto set', () => {
    props.scrollEnabled = true
    props.automaticallySetHeight = false
    const tree = shallow(<CanvasWebView {...props} />)
    const webView = tree.find('WebView')
    expect(webView.prop('bounces')).toEqual(true)
  })
})
