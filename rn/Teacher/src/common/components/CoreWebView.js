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

import React, { Component } from 'react'
import {
  findNodeHandle,
  requireNativeComponent,
  NativeModules,
  View,
} from 'react-native'

const { CoreWebViewManager } = NativeModules

const NativeWebView = requireNativeComponent('CoreWebView', null)
NativeWebView.displayName = 'WebView'

export default class CoreWebView extends Component {
  state = {
    height: null,
  }

  render () {
    const {
      automaticallySetHeight,
      contentInset,
      html,
      isOpaque,
      onError,
      onFinishedLoading,
      onMessage,
      source,
      style,
    } = this.props
    const { height } = this.state

    return (
      <View style={style}>
        <NativeWebView
          automaticallySetHeight={automaticallySetHeight}
          bounces={!automaticallySetHeight}
          contentInset={contentInset}
          isOpaque={isOpaque}
          onError={onError}
          onFinishedLoading={onFinishedLoading}
          onHeightChange={this.onHeightChange}
          onNavigation={this.onNavigation}
          onMessage={onMessage}
          ref={this.captureWebView}
          source={html ? { html } : source}
          style={height ? { height } : { flex: 1 }}
        />
      </View>
    )
  }

  captureWebView = (ref) => { this.webView = ref }

  evaluateJavaScript = (js) => {
    return CoreWebViewManager.evaluateJavaScript(findNodeHandle(this.webView), js)
  }

  onHeightChange = (event) => {
    if (this.props.automaticallySetHeight) {
      this.setState({ height: event.nativeEvent.height })
    }
  }

  onNavigation = (event) => {
    let url = event.nativeEvent.url
    if (this.props.onNavigation) {
      this.props.onNavigation(url)
    } else if (this.props.openLinksInSafari) {
      this.props.navigator.showWebView(url)
    } else {
      this.props.navigator.show(url, { deepLink: true })
    }
  }
}
