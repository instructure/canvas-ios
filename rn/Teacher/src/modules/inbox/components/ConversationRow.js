// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  TouchableHighlight,
} from 'react-native'

import { Text } from '../../../common/text'
import Avatar from '../../../common/components/Avatar'
import color from '../../../common/colors'
import { getSession } from '../../../api/session'
import i18n from 'format-message'

export type ConversationRowProps = {
  conversation: Conversation,
  drawsTopLine: boolean,
  onPress: (string) => void,
}

export default class ConversationRow extends Component<any, ConversationRowProps, any> {

  _onPress = () => {
    this.props.onPress(this.props.conversation.id)
  }

  _participantNames = (): string[] => {
    const participants = this.props.conversation.participants || []
    const session = getSession()
    const myUserId = session ? session.user.id : ''
    return participants
    .filter((p) => p.id !== myUserId)
    .map((p) => p.name)
  }

  render () {
    const c = this.props.conversation
    const subject = c.subject || i18n('(no subject)')
    const names = this._participantNames()
    const title = names.join(', ')
    const avatarUserName = names.length > 1 ? i18n('Group') : names[0]
    const containerStyles = [styles.container, styles.bottomHairline]
    if (this.props.drawsTopLine) {
      containerStyles.push(styles.topHairline)
    }
    return (<TouchableHighlight onPress={this._onPress} testID={`inbox.conversation-${c.id}`}>
              <View style={containerStyles}>
                { c.workflow_state === 'unread' && <View style={styles.unreadDot} /> }
                <View style={styles.avatar}>
                  <Avatar avatarURL={c.avatar_url} userName={avatarUserName}/>
                </View>
                <View style={styles.contentContainer}>
                  <Text style={styles.names} numberOfLines={1}>{title}</Text>
                  <Text style={styles.subject} numberOfLines={1}>{subject}</Text>
                  { c.last_message && <Text style={styles.message} numberOfLines={1}>{c.last_message}</Text> }
                </View>
              </View>
            </TouchableHighlight>)
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    padding: global.style.defaultPadding,
    backgroundColor: 'white',
  },
  contentContainer: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'flex-start',
  },
  dateContainer: {
    flexDirection: 'column',
    alignItems: 'flex-start',
  },
  avatarContainer: {
    flexDirection: 'column',
    alignItems: 'flex-start',
  },
  avatar: {
    width: 40,
    height: 40,
    marginRight: global.style.defaultPadding,
  },
  unreadDot: {
    height: 6,
    width: 6,
    backgroundColor: 'blue',
    borderRadius: 3,
    position: 'absolute',
    top: 8,
    left: 8,
  },
  topHairline: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: color.seperatorColor,
  },
  bottomHairline: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: color.seperatorColor,
  },
  names: {
    fontWeight: '600',
    fontSize: 16,
  },
  subject: {
    color: '#8B969E',
    fontSize: 14,
  },
  message: {
    color: '#8B969E',
    fontSize: 14,
  },
  date: {
    fontWeight: '500',
    fontSize: 14,
  },
})
