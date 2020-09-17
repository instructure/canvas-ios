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

import React from 'react'
import ActivityIndicatorView from './ActivityIndicatorView'
import canvas from '../../canvas-api'
import CoreWebView from './CoreWebView'

export default class AuthenticatedWebView extends React.Component<any, any> {
  webView: CoreWebView

  constructor (props: any) {
    super(props)
    this.state = {
      loading: true,
    }
  }

  evaluateJavaScript = (script: string) => {
    return this.webView.evaluateJavaScript(script)
  }

  captureRef = (c: CoreWebView) => {
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
    return <CoreWebView {...props} ref={this.captureRef} />
  }
}
