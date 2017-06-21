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
  navigator: Navigator,
}

export default class DiscussionReplies extends Component<any, Props, any> {
  render () {
    let participants = this.props.participants || {}
    let r = (<Reply participants={participants} reply={this.props.reply} depth={0} navigator={this.props.navigator}/>)

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
