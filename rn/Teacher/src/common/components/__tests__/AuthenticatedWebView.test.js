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

// @flow

import 'react-native'
import React from 'react'
import AuthenticatedWebView from '../AuthenticatedWebView'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest.unmock('../AuthenticatedWebView.js')

test('AuthenticatedWebView renders', async () => {
  jest.useFakeTimers()
  let tree = renderer.create(
    <AuthenticatedWebView source={{ uri: 'http://fillmurray.com/100/100' }}/>
  )
  await tree.getInstance().update()
  jest.runAllTicks()
  expect(tree.toJSON()).toMatchSnapshot()
})

test('AuthenticatedWebView renders without uri', async () => {
  let tree = renderer.create(
    <AuthenticatedWebView source={{ html: 'html is the coolest' }}/>
  )
  expect(tree.toJSON()).toMatchSnapshot()
})

test('AuthenticatedWebView can inject javascript and not explode', () => {
  let tree = renderer.create(
    <AuthenticatedWebView source={{ uri: 'http://fillmurray.com/100/100' }}/>
  )
  const instance = tree.getInstance()
  instance.webView = {
    evaluateJavaScript: jest.fn(),
  }
  tree.getInstance().injectJavaScript(`console.log('hello')`)
  expect(tree.getInstance().webView.evaluateJavaScript).toHaveBeenCalled()
})
