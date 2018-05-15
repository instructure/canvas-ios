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
  TouchableOpacity,
} from 'react-native'
import { Text, BOLD_FONT } from '../../../common/text'
import { LinkButton, Button } from '../../../common/buttons'
import colors from '../../../common/colors'
import Images from '../../../images'
import Avatar from '../../../common/components/Avatar'
import CanvasWebView, { type Message } from '../../../common/components/CanvasWebView'
import i18n from 'format-message'
import Navigator from '../../../routing/Navigator'
import ThreadedLinesView from '../../../common/components/ThreadedLinesView'
import { isTeacher } from '../../app'
import canvas from '../../../canvas-api'
import httpClient from '../../../canvas-api/httpClient'
import isEqual from 'lodash/isEqual'
import RichContent from '../../../common/components/RichContent'
import { featureFlagEnabled } from '@common/feature-flags'

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
}

type State = {
  rating: ?number, // used to track rating changes
  useSimpleRenderer: boolean,
}

export default class Reply extends Component<Props, State> {
  static defaultProps = {
    rateEntry: canvas.rateEntry,
    httpClient,
  }

  webView: ?CanvasWebView

  state: State = {
    rating: null,
    useSimpleRenderer: this.useSimpleRenderer(this.props.reply.message),
  }

  componentWillReceiveProps (nextProps: Props) {
    if (this.props.rating !== nextProps.rating || this.props.reply.rating_sum !== nextProps.reply.rating_sum) {
      // rating was refreshed so reset state's rating
      this.setState({ rating: null })
    }

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
      this.state.rating !== newState.rating
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
                style={{ flex: 1 }}
                html={message}
                navigator={this.props.navigator}
                ref={(ref) => { this.webView = ref }}
                onFinishedLoading={this.onLoad}
                onMessage={this.onMessage}
                heightCacheKey={reply.id}
              />
            }
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
            {!reply.deleted && this._renderButtons()}
            {this._renderMoreRepliesButton(depth, reply, maxReplyNodeDepth)}

          </View>
        </View>
      </View>
    )
  }

  onLoad = () => {
    // Get unverified images so that we can fix the urls
    this.webView && this.webView.evaluateJavaScript(`;(() => {
      let imageFiles = Array.from(document.querySelectorAll('img[data-api-returntype="File"]'))
      let unverified = imageFiles.filter(img => !(/verifier=/.test(img.src))).map(img => img.dataset.apiEndpoint)
      window.webkit.messageHandlers.canvas.postMessage(JSON.stringify({ type: 'BROKEN_IMAGES', data: unverified }))
    })()`)
  }

  onMessage = (message: Message) => {
    const body = JSON.parse(message.body)
    if (body && body.type === 'BROKEN_IMAGES') {
      this.fixBrokenImages(body.data)
    }
  }

  // Canvas does not add verifier tokens to images in cached replies :(
  fixBrokenImages = (urls: Array<string>) => {
    urls.forEach(async (url) => {
      try {
        const { data } = await httpClient().get(url)
        if (data && data.url && this.webView) {
          this.webView.evaluateJavaScript(`;(() => {
            let image = document.querySelector('img[data-api-endpoint="${url}"]')
            if (image) image.src = '${data.url}'
          })()`)
        }
      } catch (error) {}
    })
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
    const { canRate, showRating, discussionLockedForUser } = this.props
    if (discussionLockedForUser && !showRating) return

    const buttonTextAttributes = {
      fontWeight: '500',
      color: colors.grey4,
      fontSize: 16,
    }
    let containerStyles = [style.footerButtonsContainer]
    if (this.props.isLastReply) {
      containerStyles.push({ paddingBottom: 8 })
    }
    return (
      <View style={containerStyles}>
        { !discussionLockedForUser &&
          <View style={style.footerActionsContainer}>
            <LinkButton style={style.footer} textAttributes={buttonTextAttributes} onPress={this._actionReply} testID='discussion.reply-btn'>
              {i18n('Reply')}
            </LinkButton>
            { this._canEdit() &&
              <Text style={[style.footer, { color: colors.grey2, textAlign: 'center', alignSelf: 'center', paddingLeft: 10, paddingRight: 10 }]} accessible={false}>|</Text>
            }
            { this._canEdit() &&
              <LinkButton style={style.footer} textAttributes={buttonTextAttributes} onPress={this._actionEdit} testID='discussion.edit-btn'>
                {i18n('Edit')}
              </LinkButton>
            }
          </View>
        }
        { showRating &&
          <View style={style.footerRatingContainer}>
            { this.ratingCount() > 0 &&
              <Text
                style={[
                  buttonTextAttributes,
                  {
                    marginRight: 6,
                    color: this.hasRated() ? colors.primaryBrandColor : buttonTextAttributes.color,
                  },
                ]}
                testID='discussion.reply.rating-count'
              >
                ({this.formattedRatingCount()})
              </Text>
            }
            { canRate &&
              <TouchableOpacity testID='discussion.reply.rate-btn' onPress={this._actionRate}>
                <Image
                  source={this.hasRated() ? Images.discussions.rated : Images.discussions.rate}
                  style={[
                    style.ratingIcon,
                    { tintColor: this.hasRated() ? colors.primaryBrandColor : buttonTextAttributes.color },
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
    if (this.state.rating == null) {
      // User hasn't rated since refresh
      return Boolean(this.props.rating && this.props.rating > 0)
    }

    // User has tapped to rate
    return this.state.rating > 0
  }

  ratingCount (): number {
    let count = this.props.reply.rating_sum || 0

    if (this.state.rating != null) {
      // User has tapped to rate so we have to do some fancy footwork
      // to calculate the new rating count to avoid looping over every entry.

      if (!this.props.rating) {
        // This ones easy. We hadn't rated yet so we just add the local changes.
        count += this.state.rating
      } else {
        // We had rated before the local changes so we subtract the old ratings
        // and add back the changes.
        count = count - this.props.rating + this.state.rating
      }
    }

    return count
  }

  formattedRatingCount (): string {
    const count = this.ratingCount()

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

  _actionRate = async () => {
    const rating = this.hasRated() ? 0 : 1
    this.setState({ rating })
    const { context, contextID, discussionID } = this.props
    try {
      await this.props.rateEntry(context, contextID, discussionID, this.props.reply.id, rating)
    } catch (e) {
      const reverted = rating === 0 ? 1 : 0
      this.setState({ rating: reverted })
    }
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
  },
  attachmentText: {
    color: colors.link,
    fontFamily: BOLD_FONT,
    marginLeft: 6,
    fontSize: 14,
  },
})
