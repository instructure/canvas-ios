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
  Switch,
} from 'react-native'
import Row, { type RowProps } from './Row'
import i18n from 'format-message'

import { colors } from '../../stylesheet'

export type RowWithSwitchProps = RowProps & {
  value?: boolean,
  onValueChange: Function,
  disabled?: boolean,
}

export default class RowWithSwitch extends Component<RowWithSwitchProps, any> {
  onValueChange = (value: boolean) => {
    this.props.onValueChange(value, this.props.identifier)
  }

  render () {
    const accessories = <Switch {...this.props}
      testID={this.props.identifier}
      onValueChange={this.onValueChange}
      tintColor={null}
      trackColor={colors.primary} />
    const accessibilityLabel = this.props.accessibilityLabel || `${this.props.title}, ${this.props.value ? i18n('On') : i18n('Off')}`
    return (
      <Row {...this.props}
        accessories={accessories}
        accessibilityRole='switch'
        accessibilityLabel={accessibilityLabel}
        {...this.props.disabled && { accessibilityState: { disabled: true } } }
        onPress={() => { this.onValueChange(!this.props.value) }}
      />
    )
  }
}
