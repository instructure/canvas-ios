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
  Switch,
} from 'react-native'
import Row, { type RowProps } from './Row'
import i18n from 'format-message'

import colors from '../../colors'

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
    let traits = []
    if (this.props.disabled) {
      traits.push('disabled')
    }

    const accessories = <Switch {...this.props}
      testID={this.props.identifier}
      onValueChange={this.onValueChange}
      tintColor={null}
      onTintColor={colors.primaryBrandColor} />
    const accessibilityLabel = this.props.accessibilityLabel || `${this.props.title}, ${this.props.value ? i18n('On') : i18n('Off')}`
    return (
      <Row {...this.props}
        accessories={accessories}
        accessibilityLabel={accessibilityLabel}
        accessibilityTraits={traits}
        onPress={() => { this.onValueChange(!this.props.value) }}
      />
    )
  }
}
