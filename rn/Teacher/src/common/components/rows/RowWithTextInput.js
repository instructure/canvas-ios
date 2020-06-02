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

import React, { Component } from 'react'
import {
  TextInput,
  View,
} from 'react-native'
import Row, { type RowProps } from './Row'
import { createStyleSheet } from '../../stylesheet'
import i18n from 'format-message'

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
    const label = i18n('{value}, text field', {
      value: this.props.value || this.props.placeholder || i18n('Input'),
    })
    return <Row {...this.props} children={this._renderTextInput()} accessibilityLabel={label} accessible={false} />
  }

  _renderWithTitle () {
    const label = [this.props.title, this.props.value != null ? this.props.value : this.props.defaultValue]
      .filter((s) => s != null && s.length > 0)
      .join(', ')
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
        accessibilityLabel={i18n('{label}, text field', { label })}
        onPress={this.handlePress}
        accessible={false}
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

const style = createStyleSheet(colors => ({
  input: {
    flex: 1,
    color: colors.textDarkest,
  },
}))
