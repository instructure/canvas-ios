//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/**
 * @flow
 */

import React, { Component } from 'react'
import { View, WebView } from 'react-native'
import RCTSFSafariViewController from 'react-native-sfsafariviewcontroller'
import { isWebUri } from 'valid-url'
import canvas, { getSession } from '../../canvas-api'

const TEMPLATE = `<!doctype html>
<html>
<head>
  <meta name="viewport" content="width={{content-width}},
    initial-scale = 1.0, user-scalable = no" />
  <style>
    body {
      font: -apple-system-body;
      margin: 0;
      padding: 0;
      color: black;
      background-color: white;
    }
    img {
      width: auto;
      height: auto;
      max-width: 100%;
    }
    video {
      width: auto;
      height: auto;
      max-width: 100%;
    }
    #whizzy_content {
      padding: 0;
      margin: 0;
    }
    iframe {
      border: none;
      width: 100% !important;
    }
  </style>
</head>
<body>
  <div id="whizzy_content">
    {{content}}
  </div>
  <script>
    window.onload = function () {
      let interval = setInterval(function () {
        if (window.originalPostMessage) {
          let height = document.body.scrollHeight
          postMessage(JSON.stringify({type: 'UPDATE_HEIGHT', data: height }))
          clearInterval(interval)
        }
      }, 100)
    }

    // handle math
    ;(() => {
      let foundMath = !!document.querySelector('math')
      document.querySelectorAll('img.equation_image').forEach(img => {
        if (!img.dataset.mathml && !img.dataset.equationContent) return
        foundMath = true
        const div = document.createElement('div')
        div.innerHTML = img.dataset.mathml || '$$' + img.dataset.equationContent + '$$'
        img.parentNode.replaceChild(div.firstChild, img)
      })
      if (foundMath) {
        const script = document.createElement('script')
        script.src = 'https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.2/MathJax.js?config=TeX-AMS-MML_HTMLorMML'
        document.body.appendChild(script)
      }
    })()
  </script>
</body>
</html>
`

type Props = {
  html: string,
  style?: any,
  scrollEnabled: boolean,
  contentInset?: { top?: number, left?: number, bottom?: number, right?: number },
  navigator?: Navigator,
}
export default class WebContainer extends Component<Props, any> {

  constructor (props: Props) {
    super(props)
    this.state = {
      webViewHeight: props.height || 1,
    }
  }

  onLayout = ({ nativeEvent }: { nativeEvent: { layout: { width: number }}}) => {
    const { width } = nativeEvent.layout
    if (width > 0) {
      this.setState({ viewportWidth: Math.ceil(width) })
    }
  }

  onShouldStartLoadWithRequest = (event: any): boolean => {
    if (event && event.navigationType === 'click' && event.url && isWebUri(event.url)) {
      const session = getSession()
      if (session && session.baseURL && event.url.includes(session.baseURL)) {
        this.loadAuthenticatedURL(event.url)
        return false
      }

      try {
        RCTSFSafariViewController.open(event.url)
      } catch (e) {}
      return false
    }
    return true
  }

  loadAuthenticatedURL = (url: string) => {
    let authedURL = url
    canvas.getAuthenticatedSessionURL(url).then(({ data }) => {
      if (data.session_url) {
        authedURL = data.session_url
      }
      RCTSFSafariViewController.open(authedURL)
    }).catch((e) => {
      RCTSFSafariViewController.open(authedURL)
    })
  }

  render () {
    let { html, style, scrollEnabled } = this.props
    scrollEnabled = scrollEnabled === undefined ? true : scrollEnabled

    html = TEMPLATE.replace('{{content}}', html)
    html = html.replace('{{content-width}}', `${this.state.viewportWidth}`)
    const baseUrl = (getSession() || {}).baseURL

    return (
      <View style={style} onLayout={this.onLayout} testID='web-container.view'>
        {
          this.state.viewportWidth == null
            ? null
            : <WebView
                style={{ height: this.state.webViewHeight, backgroundColor: 'rgba(0, 0, 0, 0)' }}
                source={{ html: html, baseUrl }}
                onMessage={this._onMessage}
                scrollEnabled={scrollEnabled}
                contentInset={this.props.contentInset}
                onShouldStartLoadWithRequest={this.onShouldStartLoadWithRequest}
            />
        }
      </View>
    )
  }

  _onMessage = (event) => {
    const message = JSON.parse(event.nativeEvent.data)
    switch (message.type) {
      case 'UPDATE_HEIGHT':
        this.setState({ webViewHeight: message.data })
        break
    }
  }
}
