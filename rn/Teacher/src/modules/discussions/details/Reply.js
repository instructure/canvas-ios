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

/* @flow */

import React, { Component } from 'react'
import {
  Image,
  View,
  ActionSheetIOS,
  TouchableOpacity,
  TouchableHighlight,
} from 'react-native'
import { Text } from '../../../common/text'
import { LinkButton, Button } from '../../../common/buttons'
import { colors, createStyleSheet, vars } from '../../../common/stylesheet'
import Images from '../../../images'
import Avatar from '../../../common/components/Avatar'
import CanvasWebView from '../../../common/components/CanvasWebView'
import i18n from 'format-message'
import Navigator from '../../../routing/Navigator'
import ThreadedLinesView from '../../../common/components/ThreadedLinesView'
import { isTeacher } from '../../app'
import isEqual from 'lodash/isEqual'
import { logEvent } from '@common/CanvasAnalytics'
import { personDisplayName } from '../../../common/formatters'
import icon from '../../../images/inst-icons'

type ReadState = 'read' | 'unread'

export type Props = {
  reply: DiscussionReply,
  depth: number,
  readState: ReadState,
  rating: ?number,
  showRating: boolean, // true if discussion allows rating
  canRate: boolean, // true if current user can rate
  participants: { [key: string]: UserDisplay },
  context: CanvasContext,
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
  rateEntry: Function,
  isLastReply: boolean,
  isAnnouncement: boolean,
  userCanReply: ?boolean,
}

type State = {
}

export default class Reply extends Component<Props, State> {
  webView: ?CanvasWebView

  state: State = {
  }

  shouldComponentUpdate (newProps: Props, newState: State) {
    return (
      !isEqual(this.props.reply, newProps.reply) ||
      this.props.depth !== newProps.depth ||
      this.props.readState !== newProps.readState ||
      this.props.showRating !== newProps.showRating ||
      this.props.canRate !== newProps.canRate ||
      this.props.maxReplyNodeDepth !== newProps.maxReplyNodeDepth ||
      this.props.isRootReply !== newProps.isRootReply ||
      this.props.discussionLockedForUser !== newProps.discussionLockedForUser ||
      this.props.myPath.length !== newProps.myPath.length ||
      this.props.userCanReply !== newProps.userCanReply ||
      this.props.rating !== newProps.rating
    )
  }

  showAttachment = () => {
    if (this.props.reply.attachment) {
      this.props.navigator.show('/attachment', { modal: true, disableSwipeDownToDismissModal: true }, {
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
    let { reply, depth, participants, maxReplyNodeDepth, readState } = this.props
    participants = participants || {}

    let user = this._userFromParticipants(reply, participants)
    let message = reply.deleted ? `<i style="color:${colors.textDark}">${i18n('Deleted this reply.')}</i>` : reply.message
    const unreadDot = this._renderUnreadDot(reply, readState)
    return (
      <View style={style.parentRow}>
        <ThreadedLinesView reply={reply} depth={depth} avatarSize={AVATAR_SIZE} marginRight={AVATAR_MARGIN_RIGHT}/>
        <View style={style.colA}>
          { unreadDot }
          <Avatar
            testID={`discussion.reply.${reply.id}.avatar`}
            height={AVATAR_SIZE}
            key={user.id}
            avatarURL={user.avatar_image_url}
            userName={user.id === '0' ? i18n('?') : user.display_name} style={style.avatar}
            onPress={this.navigateToContextCard}
          />
          <View style={style.threadLine}/>
        </View>

        <View style={style.colB}>
          <View style={style.rowA}>
            <Text
              style={style.userName}
              accessibilityRole={this.props.isRootReply ? 'header' : 'none'}
              testID='DiscussionReply.userName'
            >
              {personDisplayName(user.display_name, user.pronouns)}
            </Text>
            <Text style={style.date}>{i18n("{ date, date, 'MMM d' } at { date, time, short }", { date: new Date(reply.updated_at) })}</Text>
            <CanvasWebView
              automaticallySetHeight
              style={{ flex: 1, margin: -vars.padding }}
              html={message}
              navigator={this.props.navigator}
              ref={(ref) => { this.webView = ref }}
              heightCacheKey={reply.id}
            />

            {!reply.deleted && reply.attachment &&
              <TouchableOpacity testID={`discussion.reply.${reply.id}.attachment`} onPress={this.showAttachment}>
                <View style={style.attachment}>
                  <Image source={Images.paperclip} style={style.attachmentIcon} />
                  <Text style={style.attachmentText}>
                    {reply.attachment.display_name}
                  </Text>
                </View>
              </TouchableOpacity>
            }

            {reply.deleted && <View style={{ marginTop: vars.padding }}/>}
            {!reply.deleted && this._renderButtons()}
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
        <Button
          containerStyle={style.moreButtonContainer}
          style={style.moreButton}
          onPress={this._actionMore}
          accessibilityLabel={repliesText}
          testID={`discussion.reply.${this.props.reply.id}.more-replies`}
        >
          {repliesText}
        </Button>
      </View>
    )
  }

  _renderButtons = () => {
    const { canRate, showRating, discussionLockedForUser, userCanReply } = this.props
    if (discussionLockedForUser && !showRating) return

    const buttonTextStyle = {
      fontWeight: '500',
      color: colors.textDark,
      fontSize: 16,
    }
    let containerStyles = [style.footerButtonsContainer]
    if (this.props.isLastReply) {
      containerStyles.push({ paddingBottom: 8 })
    }
    let ratingCount = this.formattedRatingCount()
    return (
      <View style={containerStyles}>
        { !discussionLockedForUser && userCanReply &&
          <View style={style.footerActionsContainer}>
            <LinkButton
              style={style.footer}
              textStyle={buttonTextStyle}
              onPress={this._actionReply}
              testID={`discussion.reply.${this.props.reply.id}.reply-btn`}
            >
              {i18n('Reply')}
            </LinkButton>
            <Text style={[style.footer, style.morePipe]} accessible={false}>|</Text>
            <TouchableHighlight onPress={this.showMoreOptions} testID={`Reply.${this.props.reply.id}.moreButton`}>
              <Image source={icon('more')} style={style.moreIcon} />
            </TouchableHighlight>
          </View>
        }
        { showRating &&
          <View style={style.footerRatingContainer}>
            { this.props.reply.rating_sum != null && this.props.reply.rating_sum > 0 &&
              <Text
                style={[
                  buttonTextStyle,
                  {
                    marginRight: 6,
                    color: this.hasRated() ? colors.primary : buttonTextStyle.color,
                  },
                ]}
                testID={`discussion.reply.${this.props.reply.id}.rating-count`}
                accessibilityLabel={i18n(`Number of likes: {count}`, { count: ratingCount })}
              >
                ({ratingCount})
              </Text>
            }
            { canRate &&
              <TouchableOpacity
                testID={`discussion.reply.${this.props.reply.id}.rate-btn`}
                onPress={this._actionRate}
                accessibilityLabel={i18n('Like')}
                accessibilityRole='button'
                accessibilityStates={this.hasRated() ? [ 'selected' ] : []}
              >
                <Image
                  source={this.hasRated() ? Images.discussions.rated : Images.discussions.rate}
                  style={[
                    style.ratingIcon,
                    { tintColor: this.hasRated() ? colors.primary : buttonTextStyle.color },
                  ]}
                />
              </TouchableOpacity>
            }
          </View>
        }
      </View>
    )
  }

  hasRated (): boolean {
    return Boolean(this.props.rating && this.props.rating > 0)
  }

  formattedRatingCount (): string {
    const count = this.props.reply.rating_sum || 0

    if (!this.props.canRate) {
      // If the user can't rate we show the rating count with the word 'like'
      return i18n(`{
        count, plural,
          one {# like}
          other {# likes}
      }`, { count })
    }

    return `${count}`
  }

  _renderUnreadDot (reply: DiscussionReply, state: ReadState) {
    return state === 'unread' && !reply.deleted ? (
      <View style={style.unreadDot} accessible={true} accessibilityLabel={i18n('Unread')} testID={`discussion.reply.${this.props.reply.id}.unread`} />
    ) : <View />
  }

  showMoreOptions = () => {
    let canEdit = isTeacher()
    let isUnread = this.props.readState === 'unread'
    let options = []
    if (isUnread) {
      options.push(i18n('Mark as Read'))
    } else {
      options.push(i18n('Mark as Unread'))
    }
    if (canEdit) {
      options.push(i18n('Edit'))
      options.push(i18n('Delete'))
    }
    options.push(i18n('Cancel'))
    ActionSheetIOS.showActionSheetWithOptions({
      options,
      cancelButtonIndex: options.length - 1,
      destructiveButtonIndex: canEdit ? options.length - 2 : undefined,
    }, (index) => {
      switch (index) {
        case 0:
          isUnread ? this.markAsRead() : this.props.onMarkUnread(this.props.reply.id)
          break
        case 1:
          if (canEdit) {
            this.edit()
          }
          break
        case 2:
          this.delete()
          break
      }
    })
  }

  markAsRead () {
    const {
      context,
      contextID,
      discussionID,
      reply,
    } = this.props
    this.props.markEntryAsRead(context, contextID, discussionID, reply.id)
  }

  _actionMore = () => {
    this.props.onPressMoreReplies(this.props.myPath)
  }

  _actionReply = () => {
    if (this.props.isAnnouncement) {
      logEvent('announcement_replied', { nested: true })
    } else {
      logEvent('discussion_topic_replied', { nested: true })
    }
    this.props.replyToEntry(this.props.reply.id, this.props.myPath)
  }

  edit () {
    if (this.props.isAnnouncement) {
      logEvent('announcement_reply_edited')
    } else {
      logEvent('discussion_topic_reply_edited')
    }
    const { context, contextID, discussionID, reply, myPath } = this.props
    this.props.navigator.show(
      `/${context}/${contextID}/discussion_topics/${discussionID}/reply`,
      { modal: true },
      { message: reply.message, entryID: reply.id, isEdit: true, indexPath: myPath }
    )
  }

  delete () {
    const { context, contextID, discussionID, reply, myPath } = this.props
    this.props.deleteDiscussionEntry(context, contextID, discussionID, reply.id, myPath)
  }

  _actionRate = () => {
    const rating = this.hasRated() ? 0 : 1
    const { context, contextID, discussionID } = this.props
    this.props.rateEntry(context, contextID, discussionID, this.props.reply.id, rating, this.props.myPath)
  }
}

const AVATAR_SIZE = 24
const AVATAR_MARGIN_RIGHT = 8
const unreadDotSize = 6
const style = createStyleSheet((colors, vars) => ({
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
    marginTop: vars.padding / 1.25,
  },
  rowB: {
    flex: 1,
    alignSelf: 'stretch',
  },
  threadLine: {
    backgroundColor: colors.backgroundLight,
    width: 1,
    flex: 1,
  },
  avatar: {
    height: AVATAR_SIZE,
    width: AVATAR_SIZE,
    borderRadius: AVATAR_SIZE / 2,
    backgroundColor: colors.backgroundLight,
    marginTop: vars.padding / 1.25,
  },
  unreadDot: {
    width: unreadDotSize,
    height: unreadDotSize,
    borderRadius: unreadDotSize / 2,
    backgroundColor: colors.textInfo,
    position: 'absolute',
    top: 0,
    left: unreadDotSize * -1,
  },
  userName: {
    fontSize: 14,
    fontWeight: '600',
  },
  date: {
    color: colors.textDark,
    fontSize: 12,
    marginBottom: vars.padding,
  },
  footer: {
    paddingTop: 2,
    paddingBottom: 2,
    paddingRight: 2,
    alignSelf: 'flex-end',
  },
  footerButtonsContainer: {
    marginTop: vars.padding,
    marginBottom: 8,
    flexDirection: 'row',
    flex: 1,
  },
  footerActionsContainer: {
    flexDirection: 'row',
    justifyContent: 'flex-start',
    flex: 1,
  },
  footerRatingContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-end',
    alignItems: 'center',
  },
  ratingIcon: {
    tintColor: colors.textDark,
  },
  moreContainer: {
    marginTop: vars.padding,
    marginBottom: vars.padding,
    flexDirection: 'row',
    justifyContent: 'flex-start',
    height: 27,
    flex: 1,
    paddingRight: vars.padding,
  },
  moreButton: {
    fontSize: 12,
    fontWeight: 'normal',
    color: colors.textDark,
  },
  moreButtonContainer: {
    backgroundColor: colors.backgroundLight,
    borderColor: colors.borderMedium,
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
    tintColor: colors.linkColor,
    height: 14,
    width: 14,
  },
  attachmentText: {
    color: colors.linkColor,
    fontWeight: 'bold',
    marginLeft: 4,
    fontSize: 14,
  },
  moreIcon: {
    tintColor: colors.textDark,
    resizeMode: 'contain',
    height: 24,
    width: 24,
    transform: [{ rotate: '90deg' }],
  },
  morePipe: {
    color: colors.borderMedium,
    textAlign: 'center',
    alignSelf: 'center',
    paddingLeft: 10,
    paddingRight: 10,
  },
}))
