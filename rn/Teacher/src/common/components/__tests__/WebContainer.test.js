/**
 * @flow
 */

import 'react-native'
import React from 'react'
import WebContainer from '../WebContainer'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'

jest
  .unmock('ScrollView')
  .mock('WebView', () => 'WebView')

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
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('updates height from js', () => {
  let html = '<div>hello world</div>'
  let component = renderer.create(
    <WebContainer html={html} />
  )
  const webView: any = explore(component.toJSON()).query(({ type }) => type === 'WebView')[0]
  const data = JSON.stringify({ type: 'UPDATE_HEIGHT', data: 10 })
  const message = {
    nativeEvent: { data },
  }
  webView.props.onMessage(message)
  expect(component.toJSON()).toMatchSnapshot()
})
