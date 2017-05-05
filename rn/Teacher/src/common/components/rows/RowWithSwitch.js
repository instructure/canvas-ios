// @flow

import React, { Component } from 'react'
import {
  Switch,
} from 'react-native'
import Row, { type RowProps } from './Row'

import colors from '../../colors'

type RowWithSwitchProps = RowProps & {
  value: boolean,
  identifier: string, // Used to identify the switch in the callback
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
    return <Row {...this.props} accessories={accessories} />
  }
}
