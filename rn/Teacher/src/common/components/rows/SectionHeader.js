/**
* @flow
*/

import React from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import { Text } from '../../../common/text'
import color from '../../colors'

type Props = {
  title: string,
  key?: string,
  border: 'top' | 'bottom' | 'both' | 'none',
}

export default class SectionHeader extends React.PureComponent<any, Props, any> {

  render () {
    const key = this.props.key ? this.props.key : this.props.title
    let topBorder
    let bottomBorder
    if (this.props.border === 'top' || this.props.border === 'both') {
      topBorder = styles.topHairline
    }
    if (this.props.border === 'bottom' || this.props.border === 'both') {
      bottomBorder = styles.bottomHairline
    }
    return (
      <View style={[styles.section, topBorder, bottomBorder]} key={key}>
        <Text style={styles.title}>{this.props.title}</Text>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  section: {
    flex: 1,
    height: 24,
    backgroundColor: '#F5F5F5',
    justifyContent: 'center',
    paddingLeft: 16,
    paddingRight: 8,
  },
  title: {
    fontSize: 14,
    backgroundColor: '#F5F5F5',
    color: '#73818C',
    fontWeight: '600',
  },
  topHairline: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: color.seperatorColor,
  },
  bottomHairline: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: color.seperatorColor,
  },
})
