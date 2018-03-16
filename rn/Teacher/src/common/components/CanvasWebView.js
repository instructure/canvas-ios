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
}

export type State = {
  webViewHeight: ?number,
}

export default class CanvasWebView extends Component<Props, State> {
  webView: any

  static defaultProps = {
    scrollEnabled: true,
  }

  state = {
    webViewHeight: null,
  }

  onFinishedLoading = async () => {
    !this.props.scrollEnabled && this.updateHeight()
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
      src = { html, baseURL: baseURL || getSession().baseURL }
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
        />
      </View>
    )
  }

  captureWebView = (ref: any) => { this.webView = ref }

  evaluateJavaScript = (js: string): Promise<any> => {
    return CanvasWebViewManager.evaluateJavaScript(this.getWebViewHandle(), js)
  }

  getWebViewHandle = () => findNodeHandle(this.webView)

  getHeight = (): Promise<any> => {
    return this.evaluateJavaScript(`
      document.getElementById('_end_').offsetTop;
    `)
  }

  updateHeight = async () => {
    try {
      const height = await this.getHeight()
      this.setState({ webViewHeight: height })
    } catch (error) {
      this.props.onError && this.props.onError(error)
    }
  }
}
