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

// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  TouchableHighlight,
  Image,
} from 'react-native'

import { Text } from '../../../common/text'
import Avatar from '../../../common/components/Avatar'
import color from '../../../common/colors'
import { getSession } from '../../../canvas-api'
import i18n from 'format-message'
import Images from '../../../images'
import branding from '../../../common/branding'

export type ConversationRowProps = {
  conversation: Conversation,
  drawsTopLine: boolean,
  onPress: (string) => void,
}

export default class ConversationRow extends Component<ConversationRowProps, any> {
  _onPress = () => {
    this.props.onPress(this.props.conversation.id)
  }

  _participantNames = (): string[] => {
    const participants = this.props.conversation.participants || []
    const myUserId = getSession().user.id
    return participants
      .filter((p) => p.id !== myUserId)
      .map((p) => p.name)
  }

  static extractDate = (c: Conversation): ?string => {
    if (!c.properties || c.properties.includes('last_author')) return c.last_authored_message_at || c.last_message_at
    return c.last_message_at || c.last_authored_message_at
  }

  render () {
    const c = this.props.conversation
    const subject = c.subject || i18n('No Subject')
    const names = this._participantNames()
    const nameCount = names.length
    let title = ''
    if (nameCount > 6) {
      const sample = names.slice(0, 5)
      title = i18n(
        '{names} + {count} more',
        {
          names: sample.join(', '),
          count: nameCount - sample.length,
        })
    } else {
      title = names.join(', ')
    }
    const avatarUserName = nameCount > 1 ? i18n('Group') : names[0]
    const containerStyles = [styles.container, styles.bottomHairline]
    if (this.props.drawsTopLine) {
      containerStyles.push(styles.topHairline)
    }
    const unread = c.workflow_state === 'unread'
    // $FlowFixMe
    const date = new Date(ConversationRow.extractDate(c))
    const dateTitle = i18n.date(date, 'M/d/yyyy')
    const accessibilityDateTitle = i18n.date(date, 'long')
    return (<TouchableHighlight onPress={this._onPress} testID={`inbox.conversation-${c.id}`}>
      <View style={containerStyles}>
        { unread && <View style={styles.unreadDot} accessibilityLabel={i18n('Unread')} /> }
        <View style={styles.avatar}>
          <Avatar avatarURL={c.avatar_url} userName={avatarUserName}/>
        </View>
        <View style={styles.contentContainer}>
          <View style={{ flexDirection: 'row', alignItems: 'center' }}>
            { c.starred &&
              <Image source={Images.starFilled}
                accessible={true}
                accessibilityLabel={i18n('Starred')}
                style={{ tintColor: branding.primaryBrandColor, height: 14, width: 14, marginRight: 2 }}
              />
            }
            <View style={{ flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
              <Text style={styles.names} numberOfLines={1}>{title}</Text>
              <View accessible={true} accessibilityLabel={accessibilityDateTitle}>
                <Text style={styles.date}>{dateTitle}</Text>
              </View>
            </View>
          </View>
          <Text style={styles.subject} numberOfLines={1}>{subject}</Text>
          { c.last_message &&
            <Text style={styles.message} numberOfLines={1}>{c.last_message}</Text>
          }
        </View>
      </View>
    </TouchableHighlight>)
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'flex-start',
    padding: global.style.defaultPadding,
    backgroundColor: 'white',
  },
  contentContainer: {
    flex: 1,
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
    backgroundColor: '#008EE2',
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
    flex: 1,
  },
  subject: {
    color: color.darkText,
    fontSize: 14,
  },
  message: {
    color: color.grey4,
    fontSize: 14,
  },
  date: {
    color: '#8B969E',
    fontSize: 12,
    flexShrink: 0,
  },
})
