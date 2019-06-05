//
// Copyright (C) 2017-present Instructure, Inc.
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
  TouchableOpacity,
} from 'react-native'
import { Text, BOLD_FONT } from '../../../common/text'
import { LinkButton, Button } from '../../../common/buttons'
import colors from '../../../common/colors'
import Images from '../../../images'
import Avatar from '../../../common/components/Avatar'
import CanvasWebView from '../../../common/components/CanvasWebView'
import i18n from 'format-message'
import Navigator from '../../../routing/Navigator'
import ThreadedLinesView from '../../../common/components/ThreadedLinesView'
import { isTeacher } from '../../app'
import isEqual from 'lodash/isEqual'
import RichContent from '../../../common/components/RichContent'
import { featureFlagEnabled } from '@common/feature-flags'
import { logEvent } from '@common/CanvasAnalytics'

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
  useSimpleRenderer: boolean,
}

export default class Reply extends Component<Props, State> {
  webView: ?CanvasWebView

  state: State = {
    useSimpleRenderer: this.useSimpleRenderer(this.props.reply.message),
  }

  componentWillReceiveProps (nextProps: Props) {
    if (this.props.reply.message !== nextProps.reply.message) {
      this.setState({ useSimpleRenderer: this.useSimpleRenderer(nextProps.reply.message) })
    }
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

  useSimpleRenderer (message: ?string) {
    if (!message) return true
    if (!featureFlagEnabled('simpleDiscussionRenderer')) return false
    let regex = new RegExp('<([a-zA-z]+)', 'g')
    let results = message.match(regex)
    if (!results) return false
    return results.every(result => RichContent.supportedTags.includes(result.substring(1)))
  }

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
    let { reply, depth, participants, maxReplyNodeDepth, readState } = this.props
    participants = participants || {}

    let user = this._userFromParticipants(reply, participants)
    let message = reply.deleted ? `<i style="color:${colors.grey4}">${i18n('Deleted this reply.')}</i>` : reply.message
    const unreadDot = this._renderUnreadDot(reply, readState)
    return (
      <View style={style.parentRow}>
        <ThreadedLinesView reply={reply} depth={depth} avatarSize={AVATAR_SIZE} marginRight={AVATAR_MARGIN_RIGHT}/>
        <View style={style.colA}>
          { unreadDot }
          <Avatar
            testID='reply.avatar'
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
              accessibilityTraits={this.props.isRootReply ? 'header' : 'none'}
            >
              {user.display_name}
            </Text>
            <Text style={style.date}>{i18n("{ date, date, 'MMM d' } at { date, time, short }", { date: new Date(reply.updated_at) })}</Text>
            {this.state.useSimpleRenderer || reply.deleted
              ? <RichContent html={message} navigator={this.props.navigator} />
              : <CanvasWebView
                automaticallySetHeight
                style={{ flex: 1, margin: -global.style.defaultPadding }}
                html={message}
                navigator={this.props.navigator}
                ref={(ref) => { this.webView = ref }}
                heightCacheKey={reply.id}
              />
            }
            {reply.attachment &&
              <TouchableOpacity testID={`discussion-reply.${reply.id}.attachment`} onPress={this.showAttachment}>
                <View style={style.attachment}>
                  <Image source={Images.paperclip} style={style.attachmentIcon} />
                  <Text style={style.attachmentText}>
                    {reply.attachment.display_name}
                  </Text>
                </View>
              </TouchableOpacity>
            }

            {reply.deleted && <View style={{ marginTop: global.style.defaultPadding }}/>}
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
        <Button containerStyle={style.moreButtonContainer} style={style.moreButton} onPress={this._actionMore} accessibilityLabel={repliesText} testID='discussion.more-replies'>
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
      color: colors.grey4,
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
            <LinkButton style={style.footer} textStyle={buttonTextStyle} onPress={this._actionReply} testID='discussion.reply-btn'>
              {i18n('Reply')}
            </LinkButton>
            { this._canEdit() &&
              <Text style={[style.footer, { color: colors.grey2, textAlign: 'center', alignSelf: 'center', paddingLeft: 10, paddingRight: 10 }]} accessible={false}>|</Text>
            }
            { this._canEdit() &&
              <LinkButton style={style.footer} textStyle={buttonTextStyle} onPress={this._actionEdit} testID='discussion.edit-btn'>
                {i18n('Edit')}
              </LinkButton>
            }
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
                    color: this.hasRated() ? colors.primaryBrandColor : buttonTextStyle.color,
                  },
                ]}
                testID='discussion.reply.rating-count'
                accessibilityLabel={i18n(`Number of likes: {count}`, { count: ratingCount })}
              >
                ({ratingCount})
              </Text>
            }
            { canRate &&
              <TouchableOpacity
                testID='discussion.reply.rate-btn'
                onPress={this._actionRate}
                accessibilityLabel={i18n('Like')}
                accessibilityTraits={this.hasRated() ? ['button', 'selected'] : ['button']}
              >
                <Image
                  source={this.hasRated() ? Images.discussions.rated : Images.discussions.rate}
                  style={[
                    style.ratingIcon,
                    { tintColor: this.hasRated() ? colors.primaryBrandColor : buttonTextStyle.color },
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
      <View style={style.unreadDot} accessible={true} accessibilityLabel={i18n('Unread')} />
    ) : <View />
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

  _actionEdit = () => {
    if (this.props.isAnnouncement) {
      logEvent('announcement_reply_edited')
    } else {
      logEvent('discussion_topic_reply_edited')
    }
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

  _actionRate = () => {
    const rating = this.hasRated() ? 0 : 1
    const { context, contextID, discussionID } = this.props
    this.props.rateEntry(context, contextID, discussionID, this.props.reply.id, rating, this.props.myPath)
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
    color: colors.grey5,
    fontSize: 12,
    marginBottom: global.style.defaultPadding,
  },
  footer: {
    paddingTop: 2,
    paddingBottom: 2,
    paddingRight: 2,
    alignSelf: 'flex-end',
  },
  footerButtonsContainer: {
    marginTop: global.style.defaultPadding,
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
    tintColor: colors.grey4,
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
    height: 14,
    width: 14,
  },
  attachmentText: {
    color: colors.link,
    fontFamily: BOLD_FONT,
    marginLeft: 4,
    fontSize: 14,
  },
})
