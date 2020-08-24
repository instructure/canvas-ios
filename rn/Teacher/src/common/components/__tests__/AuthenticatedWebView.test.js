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
  await Promise.resolve()
  expect(tree.toJSON()).toMatchSnapshot()
})

test('AuthenticatedWebView can inject javascript and not explode', async () => {
  let tree = renderer.create(
    <AuthenticatedWebView source={{ uri: 'http://fillmurray.com/100/100' }}/>
  )
  await Promise.resolve()
  const instance = tree.getInstance()
  instance.webView = {
    evaluateJavaScript: jest.fn(),
  }
  tree.getInstance().evaluateJavaScript(`console.log('hello')`)
  expect(tree.getInstance().webView.evaluateJavaScript).toHaveBeenCalled()
})
