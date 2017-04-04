/**
 * @flow
 */

import React, { Component } from 'react'
import { Heading1 } from '../../../common/text'
import color from '../../../common/colors'
import { PADDING } from '../../../common/globalStyle'

import {
  View,
  StyleSheet,
} from 'react-native'

export default class AssignmentSection extends Component {
  render (): ReactElement<*> {
    return (
      <View style={[style.container, this.props.style]}>
        <Heading1 style={style.header}>{this.props.title}</Heading1>
      </View>
    )
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'center',

    height: 50,
    backgroundColor: '#F5F5F5',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderTopColor: '#D8DBDE',
    borderBottomColor: '#D8DBDE',
  },
  header: {
    color: color.darkText,
    marginLeft: PADDING,
    marginTop: PADDING,
    marginBottom: PADDING / 2,
  },
})
