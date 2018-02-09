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
  reply: DiscussionReply,
}

export default class ThreadedLinesView extends PureComponent<Props> {
  render () {
    return this.createThreadDepth(this.props.depth)
  }

  renderLine (index: number = 0) {
    const { reply } = this.props || { id: '' }

    return (
      <View style={{
        flexDirection: 'column',
        justifyContent: 'flex-start',
        alignItems: 'center',
        marginRight: this.props.marginRight,
        width: this.props.avatarSize,
      }} key={`reply_line_${reply.id}_${index}`}>
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
        views.push(this.renderLine(lines))
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
