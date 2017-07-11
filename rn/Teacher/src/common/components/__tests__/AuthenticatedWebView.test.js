// @flow

import 'react-native'
import React from 'react'
import AuthenticatedWebView from '../AuthenticatedWebView'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest.unmock('../AuthenticatedWebView.js')
jest.mock('WebView', () => 'WebView')

test('AuthenticatedWebView renders', async () => {
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
