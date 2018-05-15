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

// @flow

import React from 'react'
import ActivityIndicatorView from './ActivityIndicatorView'
import canvas from '../../canvas-api'
import CanvasWebView from './CanvasWebView'

export default class AuthenticatedWebView extends React.Component<any, any> {
  webView: CanvasWebView

  constructor (props: any) {
    super(props)
    this.state = {
      loading: true,
    }
  }

  injectJavaScript = (script: string) => {
    return this.webView.evaluateJavaScript(script)
  }

  captureRef = (c: CanvasWebView) => {
    this.webView = c
  }

  componentDidMount () {
    if (this.props.source && this.props.source.uri) {
      this.update()
    } else {
      this.setState({
        loading: false,
      })
    }
  }

  async update () {
    this.setState({
      loading: true,
    })
    const uri = this.props.source.uri
    let authedUri = uri
    try {
      const result = await canvas.getAuthenticatedSessionURL(uri)
      if (result.data.session_url) {
        authedUri = result.data.session_url
      }
    } catch (e) {}
    this.setState({
      uri: authedUri,
      loading: false,
    })
  }

  render () {
    if (this.state.loading) {
      return <ActivityIndicatorView />
    }

    const uri = this.state.uri
    const props = {
      ...this.props,
      source: uri ? { uri } : this.props.source,
    }
    return <CanvasWebView {...props} ref={this.captureRef} />
  }
}
