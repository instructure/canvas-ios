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
  top?: boolean, // Draw a line at the top of the section header. Usually used if the section header is the topmost of the list
}

export default class SectionHeader extends React.PureComponent<any, Props, any> {

  render () {
    const key = this.props.key ? this.props.key : this.props.title
    const topHairline = this.props.top ? styles.topHairline : undefined
    const containerStyle = [styles.section, styles.bottomHairline, topHairline].filter(Boolean)
    return (
      <View style={containerStyle} key={key} accessibilityTraits='header'>
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
