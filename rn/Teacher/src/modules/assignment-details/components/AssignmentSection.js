/**
 * @flow
 */

import React, { Component } from 'react'
import { Heading2 } from '../../../common/text'
import color from '../../../common/colors'

import {
  View,
  StyleSheet,
} from 'react-native'

export default class AssignmentSection extends Component {
  render (): ReactElement<*> {
    let dividerStyle = {}
    let headerStyle = {}
    if (!this.props.isFirstRow) {
      dividerStyle = assignmentSectionStyles.divider
      headerStyle = assignmentSectionStyles.header
    }

    return (
      <View style={[assignmentSectionStyles.container, this.props.style]}>
        <View style={dividerStyle}></View>
        <Heading2 style={headerStyle}>{this.props.title}</Heading2>
        {this.props.children}
      </View>
    )
  }
}

const PADDING = 16

const assignmentSectionStyles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: PADDING,
    paddingLeft: PADDING,
    paddingRight: PADDING,
    paddingBottom: 5,

  },

  divider: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: color.lightText,
    paddingBottom: PADDING,
  },
  header: {
    color: color.lightText,
    marginBottom: 8,
  },
})
