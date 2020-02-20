//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/**
 * @flow
 */

import React, { PureComponent } from 'react'
import {
  View,
} from 'react-native'

import { createStyleSheet } from '../stylesheet'

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

const style = createStyleSheet(colors => ({
  threadLine: {
    backgroundColor: colors.backgroundLight,
    width: 1,
    flex: 1,
  },
}))
