// @flow

import React from 'react'
import { WebView } from 'react-native'
import ActivityIndicatorView from './ActivityIndicatorView'
import canvas from '../../api/canvas-api'

export default class AuthenticatedWebView extends React.Component<any, any, any> {

  webView: WebView

  constructor (props: any) {
    super(props)
    this.state = {
      loading: true,
    }
  }

  injectJavaScript = (script: string) => {
    this.webView.injectJavaScript(script)
  }

  captureRef = (c: WebView) => {
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
    return <WebView {...props} ref={this.captureRef} />
  }
}
