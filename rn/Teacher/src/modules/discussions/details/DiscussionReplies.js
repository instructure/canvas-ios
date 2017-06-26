/* @flow */

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import Reply from './Reply'
import Navigator from '../../../routing/Navigator'

export type Props = {
  reply: DiscussionReply,
  participants: { [key: string]: UserDisplay },
  courseID: string,
  discussionID: string,
  deleteDiscussionEntry: Function,
  replyToEntry: Function,
  onPressMoreReplies: Function,
  navigator: Navigator,
  pathIndex: number[],
}

export default class DiscussionReplies extends Component<any, Props, any> {
  render () {
    let { courseID, discussionID, deleteDiscussionEntry, pathIndex, reply, replyToEntry, onPressMoreReplies } = this.props
    let participants = this.props.participants || {}
    let r = (
     <Reply
     replyToEntry={replyToEntry}
     myPath={[...pathIndex]}
     navigator={this.props.navigator}
     deleteDiscussionEntry={deleteDiscussionEntry}
     courseID={courseID}
     discussionID={discussionID}
     participants={participants}
     reply={reply}
     onPressMoreReplies={onPressMoreReplies}
     depth={0}/>
    )
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
