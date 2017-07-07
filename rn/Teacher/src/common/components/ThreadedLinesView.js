/**
 * @flow
 */

import React, { PureComponent } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'

import colors from '../colors'

type Props = {
  depth: number,
  avatarSize: number,
  marginRight: number,
}

export default class ThreadedLinesView extends PureComponent {
  props: Props
  render () {
    return this.createThreadDepth(this.props.depth)
  }

  renderLine () {
    return (
      <View style={{
        flexDirection: 'column',
        justifyContent: 'flex-start',
        alignItems: 'center',
        marginRight: this.props.marginRight,
        width: this.props.avatarSize,
      }}>
        <View style={style.threadLine}/>
      </View>
    )
  }

  createThreadDepth (depth: number) {
    if (depth === 0) return (<View/>)
    if (depth === 1) {
      return this.renderLine()
    } else {
      let lines = depth
      let views = []
      while (lines > 0) {
        views.push(this.renderLine())
        lines--
      }
      return (
        <View style={{ flexDirection: 'row', width: (this.props.avatarSize + this.props.marginRight) * depth }}>
          {views}
        </View>
      )
    }
  }
}

const style = StyleSheet.create({
  threadLine: {
    backgroundColor: colors.grey1,
    width: 1,
    flex: 1,
  },
})
