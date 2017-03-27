/**
 * @flow
 */

import React, { Component } from 'react'
import { WebView } from 'react-native'

type Props = {
  html: string,
  style?: any,
}
export default class WebContainer extends Component<any, Props, any> {
  constructor (props: Props) {
    super(props)
    this.state = {
      webViewHeight: props.height || 0,
    }
  }

  onNavigationStateChange (event: any) {
    let height = parseInt(event.jsEvaluationValue)
    this.setState({
      webViewHeight: height,
    })
  }

  render (): ReactElement<*> {
    let { html, style } = this.props
    return (
      <WebView
        style={[style, { height: this.state.webViewHeight }]}
        source={{ html: html }}
        onNavigationStateChange={this.onNavigationStateChange.bind(this)}
        injectedJavaScript='document.body.scrollHeight;'
      />
    )
  }
}
