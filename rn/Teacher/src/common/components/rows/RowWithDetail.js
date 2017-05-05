// @flow

import React, { Component } from 'react'
import Row, { type RowProps } from './Row'
import { Text } from '../../text'

type RowWithSwitchProps = RowProps & {
  detail: string,
}

export default class RowWithDetail extends Component<any, RowWithSwitchProps, any> {

  render () {
    const accessories = <Text numberOfLines={1}>{this.props.detail}</Text>
    return <Row {...this.props} accessories={accessories} />
  }
}
