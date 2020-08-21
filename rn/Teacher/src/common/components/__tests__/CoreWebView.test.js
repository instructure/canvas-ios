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

import React from 'react'
import { NativeModules } from 'react-native'
import { shallow } from 'enzyme'
import CoreWebView from '../CoreWebView'
import * as template from '../../../__templates__'

describe('CoreWebView', () => {
  let props

  beforeEach(() => {
    jest.clearAllMocks()

    props = {
      scrollEnabled: true,
      navigator: template.navigator(),
    }
  })

  it('renders html', () => {
    const html = '<div>Hello, World!</div>'
    const tree = shallow(<CoreWebView {...props} html={html} />)
    const webView = tree.find('WebView')
    expect(webView.props().source).toEqual({ html })
  })

  it('renders uri', () => {
    const uri = 'https://apple.com'
    const tree = shallow(<CoreWebView {...props} source={{ uri }} />)
    const webView = tree.find('WebView')
    expect(webView.props().source).toEqual({ uri })
  })

  it('sends messages', () => {
    const onMessage = jest.fn()
    const tree = shallow(<CoreWebView {...props} onMessage={onMessage} />)
    const webView = tree.find('WebView')
    webView.simulate('Message', { nativeEvent: 'hello' })
    expect(onMessage).toHaveBeenCalledWith({ nativeEvent: 'hello' })
  })

  it('notifies when finished loading', () => {
    const onFinishedLoading = jest.fn()
    const tree = shallow(<CoreWebView {...props} onFinishedLoading={onFinishedLoading} />)
    const webView = tree.find('WebView')
    webView.simulate('FinishedLoading')
    expect(onFinishedLoading).toHaveBeenCalled()
  })

  it('handles navigation', () => {
    const navigator = template.navigator({ show: jest.fn() })
    const tree = shallow(<CoreWebView {...props} navigator={navigator} />)
    const webView = tree.find('WebView')
    const url = 'https://canvas.instructure.com/courses/1/assignments/1'
    webView.simulate('Navigation', { nativeEvent: { url } })
    expect(navigator.show).toHaveBeenCalledWith(url, {
      deepLink: true,
    })
  })

  it('handles navigation when openLinksInSafari is provided', async () => {
    const navigator = template.navigator({ show: jest.fn() })
    const tree = shallow(<CoreWebView {...props} navigator={navigator} openLinksInSafari />)
    const webView = tree.find('WebView')
    const url = 'https://canvas.instructure.com/courses/1/assignments/1'
    webView.simulate('Navigation', { nativeEvent: { url } })
    expect(navigator.showWebView).toHaveBeenCalledWith(url)
  })

  it('handles navigation callback', () => {
    const navigator = template.navigator({ show: jest.fn() })
    const onNavigation = jest.fn()
    const tree = shallow(<CoreWebView {...props} navigator={navigator} onNavigation={onNavigation} />)
    const webView = tree.find('WebView')
    const url = 'https://canvas.instructure.com/courses/1/assignments/1'
    webView.simulate('Navigation', { nativeEvent: { url } })
    expect(navigator.show).not.toHaveBeenCalled()
    expect(onNavigation).toHaveBeenCalledWith(url)
  })

  it('sends errors', () => {
    const onError = jest.fn()
    const tree = shallow(<CoreWebView {...props} onError={onError} />)
    const webView = tree.find('WebView')
    webView.simulate('Error', 'error')
    expect(onError).toHaveBeenCalledWith('error')
  })

  it('evaluates javascript', () => {
    const js = `console.log('Hello, World!');`
    const tree = shallow(<CoreWebView {...props} />)
    tree.instance().evaluateJavaScript(js)
    expect(NativeModules.CoreWebViewManager.evaluateJavaScript).toHaveBeenCalledWith(
      null,
      js,
    )
  })

  it('updates height to fit content if automaticallySetHeight', async () => {
    const height = 42
    const tree = shallow(<CoreWebView {...props} automaticallySetHeight />)
    const webView = tree.find('WebView')
    webView.simulate('HeightChange', { nativeEvent: { height } })
    tree.update()
    expect(tree.find('WebView').props().style.height).toEqual(42)
  })

  it('does not update height to fit content if no automaticallySetHeight', async () => {
    const height = 42
    const tree = shallow(<CoreWebView {...props} automaticallySetHeight={false} />)
    const webView = tree.find('WebView')
    webView.simulate('HeightChange', { nativeEvent: { height } })
    tree.update()
    expect(tree.find('WebView').props().style.height).not.toEqual(42)
  })

  it('prevents bounce if height is auto set', () => {
    props.automaticallySetHeight = true
    const tree = shallow(<CoreWebView {...props} />)
    const webView = tree.find('WebView')
    expect(webView.prop('bounces')).toEqual(false)
  })

  it('bounces if height is not auto set', () => {
    props.automaticallySetHeight = false
    const tree = shallow(<CoreWebView {...props} />)
    const webView = tree.find('WebView')
    expect(webView.prop('bounces')).toEqual(true)
  })
})
