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

import React, { Component } from 'react'
import {
  TextInput,
  StyleSheet,
  View,
} from 'react-native'
import Row, { type RowProps } from './Row'

type Props = RowProps & {
  defaultValue?: ?string,
  value?: ?string,
  onChangeText?: (text: string, identifier: ?string) => void,
  inputWidth?: number, // only applies with title, default is 50
  inputHeight?: number, // only applies with title, default is 50
  placeholder?: ?string,
  keyboardType?: string,
  onFocus?: Function,
}

export default class RowWithTextInput extends Component<Props, any> {
  input: ?TextInput

  static defaultProps = {
    title: '',
  }

  handlePress = (event: Event) => {
    this.props.onPress && this.props.onPress(event)
    this.input && this.input.focus()
  }

  render () {
    return this.props.title ? this._renderWithTitle() : this._renderWithoutTitle()
  }

  _renderWithoutTitle () {
    return <Row {...this.props} children={this._renderTextInput()} accessibilityLabel={this.props.value} />
  }

  _renderWithTitle () {
    const accessory = (
      <View
        style={{
          height: this.props.inputHeight || 30,
          width: this.props.inputWidth || 50,
        }}
        children={this._renderTextInput({ textAlign: 'right' })}
      />
    )
    return (
      <Row
        {...this.props}
        accessories={accessory}
        accessibilityLabel={`${this.props.title}, ${this.props.value || ''}`}
        onPress={this.handlePress}
      />
    )
  }

  _renderTextInput (styles?: any) {
    return (
      <TextInput
        defaultValue={this.props.defaultValue}
        value={this.props.value}
        onChangeText={this._onChangeText}
        testID={this.props.identifier}
        style={[style.input, styles]}
        placeholder={this.props.placeholder}
        keyboardType={this.props.keyboardType}
        onFocus={this.props.onFocus}
        ref={input => { this.input = input }}
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
