/* @flow */

import React, { Component } from 'react'
import Screen from '../../routing/Screen'

import RichTextEditor, { type Props } from '../../common/components/rich-text-editor/RichTextEditor'

export default class RichTextEditorScreen extends Component<any, Props, any> {
  render () {
    return (
      <Screen>
        <RichTextEditor {...this.props} />
      </Screen>
    )
  }
}
