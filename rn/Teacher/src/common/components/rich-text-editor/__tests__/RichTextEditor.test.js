/* @flow */

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import { RichTextEditor } from '../'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('WebView', () => 'WebView')
  .mock('ScrollView', () => 'ScrollView')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('Button', () => 'Button')

describe('RichTextEditor', () => {
  const selectWebView = (component) => {
    return explore(component.toJSON()).query(({ type }) => type === 'WebView')[0]
  }

  const postMessage = (webView, type, data) => {
    const message = { type: type, data: data }
    const event = { nativeEvent: { data: JSON.stringify(message) } }
    webView.props.onMessage(event)
  }

  const javascript = (component) => {
    const injectJavaScript = jest.fn()
    component.getInstance().webView = { injectJavaScript }
    return injectJavaScript
  }

  it('renders', () => {
    expect(
      renderer.create(
        <RichTextEditor />
      )
    ).toMatchSnapshot()
  })

  it('provides unique active editor items', () => {
    const items = jest.fn()
    const component = renderer.create(
      <RichTextEditor editorItemsChanged={items} />
    )
    const webView = selectWebView(component)
    postMessage(webView, 'CALLBACK', ['link'])

    expect(items).toHaveBeenCalledWith(['link'])

    postMessage(webView, 'CALLBACK', ['link'])
    expect(items).toHaveBeenCalledTimes(1)
  })

  it('sends input changes', () => {
    const input = jest.fn()
    const component = renderer.create(
      <RichTextEditor onInputChange={input} />
    )
    const js = javascript(component)

    const webView = selectWebView(component)
    postMessage(webView, 'EDITOR_INPUT', '<p>sends input changes</p>')

    expect(input).toHaveBeenCalledWith('<p>sends input changes</p>')
    expect(js.mock.calls).toMatchSnapshot()
  })

  it('notifies when editor focused', () => {
    const onFocus = jest.fn()
    const component = renderer.create(
      <RichTextEditor onFocus={onFocus} />
    )
    const js = javascript(component)

    const webView = selectWebView(component)
    postMessage(webView, 'EDITOR_FOCUSED')

    expect(onFocus).toHaveBeenCalled()
    expect(js.mock.calls).toMatchSnapshot()
  })

  it('responds when zss editor loads', () => {
    const component = renderer.create(
      <RichTextEditor />
    )
    const js = javascript(component)

    const webView = selectWebView(component)
    postMessage(webView, 'ZSS_LOADED')

    expect(js.mock.calls).toMatchSnapshot()
  })

  it('triggers undo', () => {
    const component = renderer.create(
      <RichTextEditor />
    )
    const js = javascript(component)

    component.getInstance().undo()

    expect(js.mock.calls).toMatchSnapshot()
  })

  it('triggers redo', () => {
    const component = renderer.create(
      <RichTextEditor />
    )
    const js = javascript(component)

    component.getInstance().redo()

    expect(js.mock.calls).toMatchSnapshot()
  })

  it('notifies when editor blurred', () => {
    const onBlur = jest.fn()
    const component = renderer.create(
      <RichTextEditor onBlur={onBlur} />
    )
    const webView = selectWebView(component)
    postMessage(webView, 'EDITOR_BLURRED')
    expect(onBlur).toHaveBeenCalled()
  })
})
