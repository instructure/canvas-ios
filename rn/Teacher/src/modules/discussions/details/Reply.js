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

/* @flow */

import React, { Component } from 'react'
import {
  Image,
  View,
  StyleSheet,
  ActionSheetIOS,
  TouchableHighlight,
} from 'react-native'
import { Text, BOLD_FONT } from '../../../common/text'
import { LinkButton, Button } from '../../../common/buttons'
import colors from '../../../common/colors'
import Images from '../../../images'
import Avatar from '../../../common/components/Avatar'
import WebContainer from '../../../common/components/WebContainer'
import i18n from 'format-message'
import Navigator from '../../../routing/Navigator'
import ThreadedLinesView from '../../../common/components/ThreadedLinesView'
import { isTeacher } from '../../app'

type ReadState = 'read' | 'unread'

export type Props = {
  reply: DiscussionReply,
  depth: number,
  readState: ReadState,
  participants: { [key: string]: UserDisplay },
  context: Context,
  contextID: string,
  discussionID: string,
  deleteDiscussionEntry: Function,
  replyToEntry: Function,
  onPressMoreReplies: Function,
  myPath: number[],
  navigator: Navigator,
  maxReplyNodeDepth: number,
  isRootReply?: boolean,
  discussionLockedForUser?: boolean,
}

export default class Reply extends Component<Props> {

  showAttachment = () => {
    if (this.props.reply.attachment) {
      this.props.navigator.show('/attachment', { modal: true }, {
        attachment: this.props.reply.attachment,
      })
    }
  }

  _userFromParticipants (reply: DiscussionReply, participants: { [key: string]: UserDisplay }): UserDisplay {
    // $FlowFixMe
    let user = participants[reply.user_id ? reply.user_id : reply.editor_id]
    if (!user) {
      user = {
        id: '0',
        display_name: i18n('Unknown Author'),
        avatar_image_url: '',
        avatar_url: '',
        short_name: '',
        html_url: '',
      }
    }
    return user
  }

  navigateToContextCard = () => {
    let user = this._userFromParticipants(this.props.reply, this.props.participants)
    this.props.navigator.show(
      `/${this.props.context}/${this.props.contextID}/users/${user.id}`,
      { modal: true }
    )
  }

  render () {
    let { reply, depth, participants, maxReplyNodeDepth, readState, discussionLockedForUser } = this.props
    participants = participants || {}

    let user = this._userFromParticipants(reply, participants)
    let message = reply.deleted ? `<i style="color:${colors.grey4}">${i18n('Deleted this reply.')}</i>` : reply.message
    const unreadDot = this._renderUnreadDot(reply, readState)
    return (
      <View style={style.parentRow}>
        <ThreadedLinesView reply={reply} depth={depth} avatarSize={AVATAR_SIZE} marginRight={AVATAR_MARGIN_RIGHT}/>
        <View style={style.colA}>
          { unreadDot }
          {user &&
            <Avatar
              testID='reply.avatar'
              height={AVATAR_SIZE}
              key={user.id}
              avatarURL={user.avatar_image_url}
              userName={user.id === '0' ? i18n('?') : user.display_name} style={style.avatar}
              onPress={this.navigateToContextCard}
            />
          }
          <View style={style.threadLine}/>
        </View>

        <View style={style.colB}>
          <View style={style.rowA}>
            {user &&
              <Text
                style={style.userName}
                accessibilityTraits={this.props.isRootReply ? 'header' : 'none'}
              >
                {user.display_name}
              </Text>
            }
            <Text style={style.date}>{i18n("{ date, date, 'MMM d' } at { date, time, short }", { date: new Date(reply.updated_at) })}</Text>
            <WebContainer scrollEnabled={false} style={{ flex: 1 }} html={message} navigator={this.props.navigator}/>

            {reply.attachment &&
              <TouchableHighlight testID={`discussion-reply.${reply.id}.attachment`} onPress={this.showAttachment}>
                <View style={style.attachment}>
                  <Image source={Images.attachment} style={style.attachmentIcon} />
                  <Text style={style.attachmentText}>
                    {reply.attachment.display_name}
                  </Text>
                </View>
              </TouchableHighlight>
            }

            {reply.deleted && <View style={{ marginTop: global.style.defaultPadding }}/>}
            {(!reply.deleted && !discussionLockedForUser) && this._renderButtons()}
            {this._renderMoreRepliesButton(depth, reply, maxReplyNodeDepth)}

          </View>
        </View>
      </View>
    )
  }

  _renderMoreRepliesButton = (depth: number, reply: DiscussionReply, maxReplyNodeDepth: number) => {
    let showMoreButton = depth === maxReplyNodeDepth
    let replies = reply.replies || []
    if (!(showMoreButton && replies.length > 0)) { return (<View/>) }
    let repliesText = i18n('View more replies')
    return (
      <View style={style.moreContainer}>
        <Button containerStyle={style.moreButtonContainer} style={style.moreButton} onPress={this._actionMore} accessibilityLabel={repliesText} testID='discussion.more-replies'>
          {repliesText}
        </Button>
      </View>
    )
  }

  _renderButtons = () => {
    return (
      <View style={style.footerContainer}>
       <LinkButton style={style.footer} textAttributes={{ fontWeight: '500', color: colors.grey4 }} onPress={this._actionReply} testID='discussion.reply-btn'>
            {i18n('Reply')}
        </LinkButton>
      {this._canEdit() && <Text style={[style.footer, { color: colors.grey2, textAlign: 'center', alignSelf: 'center', paddingLeft: 10, paddingRight: 10 }]} accessible={false}>|</Text>}
      {this._canEdit() && <LinkButton style={style.footer} textAttributes={{ fontWeight: '500', color: colors.grey4 }} onPress={this._actionEdit} testID='discussion.edit-btn'>
          {i18n('Edit')}
      </LinkButton>}
      </View>
    )
  }

  _renderUnreadDot (reply: DiscussionReply, state: ReadState) {
    return state === 'unread' && !reply.deleted ? (<View style={style.unreadDot}/>) : <View />
  }

  _actionMore = () => {
    this.props.onPressMoreReplies(this.props.myPath)
  }

  _actionReply = () => {
    this.props.replyToEntry(this.props.reply.id, this.props.myPath)
  }

  _actionEdit = () => {
    const { context, contextID, discussionID } = this.props
    let options = []
    options.push(i18n('Edit'))
    options.push(i18n('Delete'))
    options.push(i18n('Cancel'))
    ActionSheetIOS.showActionSheetWithOptions({
      options: options,
      cancelButtonIndex: options.length - 1,
      destructiveButtonIndex: options.length - 2,
    }, (button) => {
      if (button === (options.length - 1)) { return }
      if (button === (options.length - 2)) { this.props.deleteDiscussionEntry(context, contextID, discussionID, this.props.reply.id, this.props.myPath); return }
      if (button === 0) {
        this.props.navigator.show(`/${context}/${contextID}/discussion_topics/${this.props.discussionID}/reply`, { modal: true }, { message: this.props.reply.message, entryID: this.props.reply.id, isEdit: true, indexPath: this.props.myPath })
        return
      }
    })
  }

  _canEdit = () => {
    return isTeacher()
  }
}

const AVATAR_SIZE = 24
const AVATAR_MARGIN_RIGHT = 8
const unreadDotSize = 6
const style = StyleSheet.create({
  parentRow: {
    flex: 1,
    flexDirection: 'row',
  },
  colA: {
    flexDirection: 'column',
    justifyContent: 'flex-start',
    alignItems: 'center',
    paddingTop: unreadDotSize,
    marginTop: 10,
    marginRight: AVATAR_MARGIN_RIGHT,
  },
  colB: {
    flex: 1,
  },
  rowA: {
    alignSelf: 'stretch',
    marginTop: global.style.defaultPadding / 1.25,
  },
  rowB: {
    flex: 1,
    alignSelf: 'stretch',
  },
  threadLine: {
    backgroundColor: colors.grey1,
    width: 1,
    flex: 1,
  },
  avatar: {
    height: AVATAR_SIZE,
    width: AVATAR_SIZE,
    borderRadius: AVATAR_SIZE / 2,
    backgroundColor: colors.grey1,
    marginTop: global.style.defaultPadding / 1.25,
  },
  unreadDot: {
    width: unreadDotSize,
    height: unreadDotSize,
    borderRadius: unreadDotSize / 2,
    backgroundColor: '#008EE4',
    position: 'absolute',
    top: 0,
    left: unreadDotSize * -1,
  },
  userName: {
    fontSize: 14,
    fontWeight: '600',
  },
  date: {
    color: colors.grey4,
    fontSize: 12,
    marginBottom: global.style.defaultPadding,
  },
  footer: {
    paddingTop: 2,
    paddingBottom: 2,
    paddingRight: 2,
    alignSelf: 'flex-end',
  },
  footerContainer: {
    marginTop: global.style.defaultPadding,
    flexDirection: 'row',
    justifyContent: 'flex-start',
  },
  moreContainer: {
    marginTop: global.style.defaultPadding,
    marginBottom: global.style.defaultPadding,
    flexDirection: 'row',
    justifyContent: 'flex-start',
    height: 27,
    flex: 1,
    paddingRight: global.style.defaultPadding,
  },
  moreButton: {
    fontSize: 12,
    fontWeight: 'normal',
    color: colors.grey4,
  },
  moreButtonContainer: {
    backgroundColor: colors.grey1,
    borderColor: colors.grey2,
    borderWidth: 1,
    borderRadius: 4,
    flex: 1,
    padding: 5,
  },
  attachment: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  attachmentIcon: {
    tintColor: colors.link,
  },
  attachmentText: {
    color: colors.link,
    fontFamily: BOLD_FONT,
    marginLeft: 6,
    fontSize: 14,
  },
})
