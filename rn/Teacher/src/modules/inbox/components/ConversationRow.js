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

// @flow

import React, { Component } from 'react'
import {
  View,
  TouchableHighlight,
  Image,
} from 'react-native'

import { Text } from '../../../common/text'
import Avatar from '../../../common/components/Avatar'
import { getSession } from '../../../canvas-api'
import i18n from 'format-message'
import icon from '../../../images/inst-icons'
import { colors, createStyleSheet } from '../../../common/stylesheet'
import { personDisplayName } from '../../../common/formatters'

export type ConversationRowProps = {
  conversation: Conversation,
  drawsTopLine: boolean,
  onPress: (string) => void,
}

export default class ConversationRow extends Component<ConversationRowProps, any> {
  _onPress = () => {
    this.props.onPress(this.props.conversation.id)
  }

  _participants = (): string[] => {
    const participants = this.props.conversation.participants || []
    const myUserId = getSession().user.id
    return participants.filter((p) => p.id !== myUserId)
  }

  static extractDate = (c: Conversation): ?string => {
    if (!c.properties || c.properties.includes('last_author')) return c.last_authored_message_at || c.last_message_at
    return c.last_message_at || c.last_authored_message_at
  }

  render () {
    const c = this.props.conversation
    const subject = c.subject || i18n('No Subject')
    const participants = this._participants()
    const names = participants.map((p) => personDisplayName(p.name, p.pronouns))
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
    const avatarUserName = nameCount > 1 ? i18n('Group') : (participants[0] || {}).name
    const containerStyles = [styles.container, styles.bottomHairline]
    if (this.props.drawsTopLine) {
      containerStyles.push(styles.topHairline)
    }
    const unread = c.workflow_state === 'unread'
    // $FlowFixMe
    const date = new Date(ConversationRow.extractDate(c))
    const dateTitle = i18n.date(date, 'M/d/yyyy')
    const accessibilityDateTitle = i18n.date(date, 'long')
    const accessibilityLabel = [accessibilityDateTitle, subject]
    if (c.starred) {
      accessibilityLabel.push(i18n('Starred'))
    }
    if (unread) {
      accessibilityLabel.push(i18n('Unread'))
    }
    let testID = `ConversationRow.${c.id}`
    return (
      <TouchableHighlight
        onPress={this._onPress}
        testID={`inbox.conversation-${c.id}`}
        accessibilityLabel={accessibilityLabel.join(', ')}
      >
        <View style={containerStyles}>
          { unread && <View testID={`${testID}.unreadIndicator`} style={styles.unreadDot} /> }
          <View style={styles.avatar}>
            <Avatar avatarURL={c.avatar_url} userName={avatarUserName}/>
          </View>
          <View style={styles.contentContainer}>
            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
              { c.starred &&
                <Image
                  source={icon('star', 'solid')}
                  style={{ tintColor: colors.primary, height: 14, width: 14, marginRight: 2 }}
                  testID={`${testID}.starredIndicator`}
                />
              }
              <View style={{ flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
                <Text style={styles.names} numberOfLines={1} testID={`${testID}.names`}>{title}</Text>
                <View>
                  <Text style={styles.date} testID={`${testID}.date`}>{dateTitle}</Text>
                </View>
              </View>
            </View>
            <Text style={styles.subject} numberOfLines={1}>{subject}</Text>
            { c.last_message &&
              <Text style={styles.message} numberOfLines={1}>{c.last_message}</Text>
            }
          </View>
        </View>
      </TouchableHighlight>
    )
  }
}

const styles = createStyleSheet((colors, vars) => ({
  container: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'flex-start',
    paddingLeft: vars.padding,
    paddingRight: vars.padding,
    paddingTop: 8,
    paddingBottom: 8,
    backgroundColor: colors.backgroundLightest,
  },
  contentContainer: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'flex-start',
  },
  avatar: {
    width: 40,
    height: 40,
    marginRight: vars.padding,
  },
  unreadDot: {
    height: 6,
    width: 6,
    backgroundColor: colors.electric,
    borderRadius: 3,
    position: 'absolute',
    top: 8,
    left: 8,
  },
  topHairline: {
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
  },
  bottomHairline: {
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
  },
  names: {
    fontWeight: '600',
    fontSize: 16,
    flex: 1,
    marginBottom: 2,
  },
  subject: {
    color: colors.textDarkest,
    fontWeight: '600',
    fontSize: 14,
    marginTop: 3,
    marginBottom: 2,
  },
  message: {
    color: colors.textDark,
    fontSize: 14,
    marginTop: 3,
    marginBottom: 3,
  },
  date: {
    color: colors.textDark,
    fontSize: 12,
    flexShrink: 0,
  },
}))
