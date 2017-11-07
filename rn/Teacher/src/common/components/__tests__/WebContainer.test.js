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

/**
 * @flow
 */

import 'react-native'
import React from 'react'
import WebContainer from '../WebContainer'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'
import RCTSFSafariViewController from 'react-native-sfsafariviewcontroller'
import api, { setSession } from '../../../canvas-api'

jest
  .unmock('ScrollView')
  .mock('WebView', () => 'WebView')
  .mock('../../../routing/Screen')
  .mock('react-native-sfsafariviewcontroller', () => {
    return {
      open: jest.fn(),
    }
  })
  .mock('../../../canvas-api')

const template = {
  ...require('../../../__templates__/session'),
  ...require('../../../__templates__/helm'),
}

beforeAll(() => {
  setSession(template.session())
})

test('render', () => {
  let tree = renderer.create(
    <WebContainer />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render html', () => {
  let html = '<div>hello world</div>'
  let tree = renderer.create(
    <WebContainer html={html} />
  )
  var width = { nativeEvent: { layout: { width: 300 } } }
  tree.getInstance().onLayout(width)
  expect(tree.toJSON()).toMatchSnapshot()
})

test('render with width zero', () => {
  let html = '<div>hello world</div>'
  let tree = renderer.create(
    <WebContainer html={html} />
  )
  var width = { nativeEvent: { layout: { width: 0 } } }
  tree.getInstance().onLayout(width)
  expect(tree.toJSON()).toMatchSnapshot()
})

test('updates height from js', () => {
  let html = '<div>hello world</div>'
  let component = renderer.create(
    <WebContainer html={html} />
  )
  var width = { nativeEvent: { layout: { width: 300 } } }
  component.getInstance().onLayout(width)

  const webView: any = explore(component.toJSON()).query(({ type }) => type === 'WebView')[0]
  const data = JSON.stringify({ type: 'UPDATE_HEIGHT', data: 10 })
  const message = {
    nativeEvent: { data },
  }

  webView.props.onMessage(message)
  expect(component.toJSON()).toMatchSnapshot()
})

test('updates height from js with scroll disabled', () => {
  let html = '<div>hello world</div>'
  let component = renderer.create(
    <WebContainer html={html} scrollEnabled={false}/>
  )
  var width = { nativeEvent: { layout: { width: 300 } } }
  component.getInstance().onLayout(width)

  const webView: any = explore(component.toJSON()).query(({ type }) => type === 'WebView')[0]
  const data = JSON.stringify({ type: 'UPDATE_HEIGHT', data: 10 })
  const message = {
    nativeEvent: { data },
  }

  webView.props.onMessage(message)
  expect(component.toJSON()).toMatchSnapshot()
})

// External links
test('external links', () => {
  let html = '<div>hello world</div>'
  let tree = renderer.create(
    <WebContainer html={html} />
  )
  var width = { nativeEvent: { layout: { width: 300 } } }
  tree.getInstance().onLayout(width)
  const webView: any = explore(tree.toJSON()).query(({ type }) => type === 'WebView')[0]
  webView.props.onShouldStartLoadWithRequest()
  expect(RCTSFSafariViewController.open).not.toHaveBeenCalled()
  webView.props.onShouldStartLoadWithRequest({
    url: 'http://www.google.com',
    navigationType: 'click',
  })
  expect(RCTSFSafariViewController.open).toHaveBeenCalledWith('http://www.google.com')
})

test('external link that does not exist', () => {
  jest.resetAllMocks()
  let html = '<div>hello world</div>'
  let tree = renderer.create(
    <WebContainer html={html} />
  )
  var width = { nativeEvent: { layout: { width: 300 } } }
  tree.getInstance().onLayout(width)
  const webView: any = explore(tree.toJSON()).query(({ type }) => type === 'WebView')[0]
  webView.props.onShouldStartLoadWithRequest()
  expect(RCTSFSafariViewController.open).not.toHaveBeenCalled()
  webView.props.onShouldStartLoadWithRequest()
  expect(RCTSFSafariViewController.open).not.toHaveBeenCalled()
})

test('external link, then reload of the content', () => {
  jest.resetAllMocks()
  let html = '<div>hello world</div>'
  let tree = renderer.create(
    <WebContainer html={html} />
  )
  var width = { nativeEvent: { layout: { width: 300 } } }
  tree.getInstance().onLayout(width)
  const webView: any = explore(tree.toJSON()).query(({ type }) => type === 'WebView')[0]
  webView.props.onShouldStartLoadWithRequest()
  expect(RCTSFSafariViewController.open).not.toHaveBeenCalled()
  webView.props.onShouldStartLoadWithRequest({
    url: 'http://www.google.com',
    navigationType: 'click',
  })
  expect(RCTSFSafariViewController.open).toHaveBeenCalledWith('http://www.google.com')
  jest.resetAllMocks()
  webView.props.onShouldStartLoadWithRequest({
    url: 'about:blank',
    navigationType: 'other',
  })
  expect(RCTSFSafariViewController.open).not.toHaveBeenCalled()
})

test('internal link loads authenticated url', async () => {
  jest.resetAllMocks()
  let html = '<div>hello world</div>'
  const navigator = template.navigator({
    show: jest.fn(),
  })
  let tree = renderer.create(
    <WebContainer html={html} navigator={navigator} />
  )
  var width = { nativeEvent: { layout: { width: 300 } } }
  tree.getInstance().onLayout(width)
  const webView: any = explore(tree.toJSON()).query(({ type }) => type === 'WebView')[0]
  webView.props.onShouldStartLoadWithRequest()
  expect(RCTSFSafariViewController.open).not.toHaveBeenCalled()

  api.getAuthenticatedSessionURL.mockReturnValueOnce(Promise.resolve({ data: { session_url: 'http://mobiledev.instructure.com/courses/1/modules/1/items-authenticated' } }))

  await webView.props.onShouldStartLoadWithRequest({
    url: 'http://mobiledev.instructure.com/courses/1/modules/1/items',
    navigationType: 'click',
  })
  expect(RCTSFSafariViewController.open).toHaveBeenCalledWith('http://mobiledev.instructure.com/courses/1/modules/1/items-authenticated')
})
