/**
 * @flow
 */

import 'react-native'
import React from 'react'
import WebContainer from '../WebContainer'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'
import RCTSFSafariViewController from 'react-native-sfsafariviewcontroller'

jest
  .unmock('ScrollView')
  .mock('WebView', () => 'WebView')
  .mock('react-native-sfsafariviewcontroller', () => {
    return {
      open: jest.fn(),
    }
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
