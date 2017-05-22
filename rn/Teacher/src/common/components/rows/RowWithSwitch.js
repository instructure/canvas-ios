// @flow

import React, { Component } from 'react'
import {
  Switch,
} from 'react-native'
import Row, { type RowProps } from './Row'
import i18n from 'format-message'

import colors from '../../colors'

type RowWithSwitchProps = RowProps & {
  value: boolean,
  onValueChange: Function,
}

export default class RowWithSwitch extends Component<any, RowWithSwitchProps, any> {

  onValueChange = (value: boolean) => {
    this.props.onValueChange(value, this.props.identifier)
  }

  render () {
    const accessories = <Switch {...this.props}
                                testID={this.props.identifier}
                                onValueChange={this.onValueChange}
                                tintColor={ colors.primaryBrandColor}
                                onTintColor={ colors.primaryBrandColor} />
    const accessibilityLabel = this.props.accessibilityLabel || `${this.props.title}, ${this.props.value ? i18n('On') : i18n('Off')}`
    return (
      <Row {...this.props}
        accessories={accessories}
        accessibilityLabel={accessibilityLabel}
        onPress={() => { this.onValueChange(!this.props.value) }}
      />
    )
  }
}
