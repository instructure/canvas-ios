/* @flow */

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import Reply from './Reply'
import Navigator from '../../../routing/Navigator'

export type Props = {
  replies: DiscussionReply[],
  participants: { [key: string]: UserDisplay },
  navigator: Navigator,
}

export default class DiscussionReplies extends Component<any, Props, any> {
  render () {
    let replies = this.props.replies || []
    let participants = this.props.participants || {}
    let r = replies.map((r: DiscussionReply) => <Reply participants={participants} reply={r} depth={0} navigator={this.props.navigator}/>)

    return (
      <View style={style.container}>
        {r}
      </View>
    )
  }
}

const style = StyleSheet.create({
  container: { flex: 1 },
})
