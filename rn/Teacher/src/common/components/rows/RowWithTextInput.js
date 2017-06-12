// @flow

import React, { Component } from 'react'
import {
  TextInput,
  StyleSheet,
  View,
} from 'react-native'
import Row, { type RowProps } from './Row'

type Props = RowProps & {
  defaultValue?: ?string,
  onChangeText?: (text: string, identifier: string) => void,
  inputWidth?: number, // only applies with title, default is 50
  inputHeight?: number, // only applies with title, default is 50
  placeholder?: ?string,
  keyboardType?: string,
  onFocus?: Function,
}

const ACCESSIBILITY_TRAITS = ['button']

export default class RowWithTextInput extends Component<any, Props, any> {

  render () {
    return this.props.title ? this._renderWithTitle() : this._renderWithoutTitle()
  }

  _renderWithoutTitle () {
    return <Row {...this.props} children={this._renderTextInput()} accessibilityTraits={ACCESSIBILITY_TRAITS} />
  }

  _renderWithTitle () {
    const accessory = (
      <View
        style={{
          height: this.props.inputHeight || 50,
          width: this.props.inputWidth || 50,
        }}
        children={this._renderTextInput({ textAlign: 'right' })}
      />
    )
    return <Row {...this.props} accessories={accessory} accessibilityTraits={ACCESSIBILITY_TRAITS} />
  }

  _renderTextInput (styles?: any) {
    return (
      <TextInput
        defaultValue={this.props.defaultValue}
        onChangeText={this._onChangeText}
        testID={this.props.identifier}
        style={[style.input, styles]}
        placeholder={this.props.placeholder}
        keyboardType={this.props.keyboardType}
        onFocus={this.props.onFocus}
      />
    )
  }

  _onChangeText = (text: string) => {
    if (this.props.onChangeText) {
      this.props.onChangeText(text, this.props.identifier)
    }
  }
}

const style = StyleSheet.create({
  input: {
    flex: 1,
  },
})
