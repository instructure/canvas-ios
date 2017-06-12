// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import Row, { type RowProps } from './Row'
import { Text } from '../../text'

type RowWithSwitchProps = RowProps & {
  detail: string,
  detailTestID?: string,
}

export default class RowWithDetail extends Component<any, RowWithSwitchProps, any> {

  render () {
    const accessories = (
      <View style={style.accessories}>
        <Text numberOfLines={1} testID={this.props.detailTestID}>{this.props.detail}</Text>
        {this.props.accessories}
      </View>
    )
    const accessibilityLabel = this.props.accessibilityLabel || [this.props.title, this.props.detail].filter(l => l).join(', ')
    return <Row {...this.props} accessories={accessories} accessibilityLabel={accessibilityLabel} />
  }
}

const style = StyleSheet.create({
  accessories: {
    flexDirection: 'row',
    alignItems: 'center',
  },
})
