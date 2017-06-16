// @flow

import React, { PureComponent } from 'react'
import { TextInput } from 'react-native'

type State = { height: number }
type Props = {
  defaultHeight: number,
  style?: any,
  onContentSizeChange?: Function,
}

export default class AutoGrowingTextInput extends PureComponent {
  props: Props
  state: State

  constructor (props: Props) {
    super(props)

    this.state = { height: this.props.defaultHeight }
  }

  updateContentSize = (e: any) => {
    this.setState({ height: Math.max(e.nativeEvent.contentSize.height, this.props.defaultHeight) })
    this.props.onContentSizeChange && this.props.onContentSizeChange(e)
  }

  render () {
    return (
      <TextInput
        {...this.props}
        style={[this.props.style, { height: this.state.height }]}
        multiline
        onContentSizeChange={this.updateContentSize}
        scrollEnabled={false}
      />
    )
  }
}
