// @flow

import React, { Component } from 'react'
import {
  findNodeHandle,
  requireNativeComponent,
  NativeModules,
  View,
  Image,
} from 'react-native'
import { getSession } from '../../canvas-api/session'

import isEqual from 'lodash/isEqual'

const { CanvasWebViewManager } = NativeModules
const { resolveAssetSource } = Image

const WebView = requireNativeComponent('CanvasWebView', null)

// $FlowFixMe - Need this for tests
WebView.displayName = 'WebView'

export type Message = { body: any }

export type Props = {
  html?: ?string,
  source?: ?{ html?: ?string, uri?: ?string } | ?number,
  style?: any,
  scrollEnabled: boolean,
  navigator: Navigator,
  contentInset?: { top?: number, left?: number, bottom?: number, right?: number },
  onFinishedLoading?: () => void,
  onMessage?: (message: Message) => void,
  onError?: (error: any) => void,
  automaticallyAdjustContentInsets?: boolean,
  baseURL?: ?string,
  heightCacheKey?: any,
}

export type State = {
  webViewHeight: ?number,
}

export const heightCache: Map<any, number> = new Map()

export default class CanvasWebView extends Component<Props, State> {
  webView: any

  static defaultProps = {
    scrollEnabled: true,
  }

  state = {
    webViewHeight: this.props.heightCacheKey ? heightCache.get(this.props.heightCacheKey) : null,
  }

  onFinishedLoading = async () => {
    this.props.onFinishedLoading && this.props.onFinishedLoading()
  }

  onNavigation = (event: { nativeEvent: { url: string } }) => {
    this.props.navigator.show(event.nativeEvent.url, {
      deepLink: true,
    })
  }

  onMessage = (event: { nativeEvent: Message }) => {
    this.props.onMessage && this.props.onMessage(event.nativeEvent)
  }

  onError = (error: any) => {
    this.props.onError && this.props.onError(error)
  }

  onHeightChange = (event: { nativeEvent: { height: number } }) => {
    if (this.props.scrollEnabled) return
    const height = event.nativeEvent.height
    this.setHeight(height)
  }

  setHeight = (webViewHeight: ?number) => {
    if (this.props.heightCacheKey) {
      if (webViewHeight) {
        heightCache.set(this.props.heightCacheKey, webViewHeight)
      } else {
        heightCache.delete(this.props.heightCacheKey)
      }
    }
    this.setState({ webViewHeight })
  }

  componentWillReceiveProps (newProps: Props) {
    this.setHeight(null)
  }

  shouldComponentUpdate (newProps: Props, newState: State) {
    return (
      this.state.webViewHeight !== newState.webViewHeight ||
      !isEqual(newProps, this.props)
    )
  }

  render () {
    const { html, source, style, baseURL } = this.props
    let src
    if (html) {
      src = { html, baseUrl: baseURL || getSession().baseURL }
    } else {
      src = source
    }
    const { webViewHeight } = this.state
    const webViewStyle = webViewHeight ? { height: webViewHeight } : { flex: 1 }
    return (
      <View style={style} testID='web-container.view'>
        <WebView
          {...this.props}
          ref={this.captureWebView}
          style={webViewStyle}
          source={resolveAssetSource(src)}
          onMessage={this.onMessage}
          onFinishedLoading={this.onFinishedLoading}
          onNavigation={this.onNavigation}
          onError={this.onError}
          onHeightChange={this.onHeightChange}
        />
      </View>
    )
  }

  captureWebView = (ref: any) => { this.webView = ref }

  evaluateJavaScript = (js: string): Promise<any> => {
    return CanvasWebViewManager.evaluateJavaScript(this.getWebViewHandle(), js)
  }

  getWebViewHandle = () => findNodeHandle(this.webView)
}
