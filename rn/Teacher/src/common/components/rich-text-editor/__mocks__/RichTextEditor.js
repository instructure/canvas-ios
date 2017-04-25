/* @flow */

import React from 'react'
import {
  View,
  Text,
} from 'react-native'

const RealRichText = require.requireActual('../RichTextEditor').default

export default class RichText extends RealRichText {
  constructor (props: any) {
    super(props)

    this.state = {
      triggers: [],
    }
  }

  render () {
    return (
      <View {...this.props} testID='rich-text-editor'>
        <Text>{this.props.html}</Text>
        <Text>Triggers: {this.state.triggers.join('\n')}</Text>
        <View>
          { super.render() }
        </View>
      </View>
    )
  }
}

// $FlowFixMe
Object.defineProperty(RichText.prototype, 'webView', {
  get: function () {
    return {
      injectJavaScript: (trigger) => {
        this.setState({ triggers: this.state.triggers.concat([trigger]) })
      },
    }
  },

  set: () => {},
})
