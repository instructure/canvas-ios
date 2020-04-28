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
import { connect } from 'react-redux'
import {
  View,
  TouchableHighlight,
  TouchableOpacity,
  Image,
  FlatList,
  ActionSheetIOS,
  Alert,
  NativeModules,
} from 'react-native'
import i18n from 'format-message'
import DetailActions from './actions'
import EditActions from '../edit/actions'
import PermissionsActions from '../../permissions/actions'
import AssignmentSection from '../../assignment-details/components/AssignmentSection'
import AssignmentDates from '../../assignment-details/components/AssignmentDates'
import CanvasWebView from '../../../common/components/CanvasWebView'
import Avatar from '../../../common/components/Avatar'
import PublishedIcon from '../../assignment-details/components/PublishedIcon'
import SubmissionBreakdownGraphSection from '../../assignment-details/components/SubmissionBreakdownGraphSection'
import GroupTopicChildren from './GroupTopicChildren'
import Images from '../../../images'
import icon from '../../../images/inst-icons'
import {
  Heading1,
  Text,
  SubTitle,
} from '../../../common/text'
import { colors, createStyleSheet, vars } from '../../../common/stylesheet'
import refresh from '../../../utils/refresh'
import Screen from '../../../routing/Screen'
import Reply from './Reply'
import { replyFromLocalIndexPath } from '../reducer'
import { type TraitCollection } from '../../../routing/Navigator'
import { isRegularDisplayMode } from '../../../routing/utils'
import { isTeacher, isStudent } from '../../app'
import { alertError } from '../../../redux/middleware/error-handler'
import { logEvent } from '../../../common/CanvasAnalytics'
import * as canvas from '../../../canvas-api'
import { personDisplayName } from '../../../common/formatters'

const { NativeAccessibility, ModuleItemsProgress } = NativeModules
const { markTopicAsRead } = canvas

type EntryRatings = { [string]: number }

type OwnProps = {
  announcementID: string,
  discussionID: string,
  context: CanvasContext,
  contextID: string,
}

type State = {
  discussion: ?Discussion,
  assignment: ?Assignment,
  courseColor: ?string,
  courseName: string,
  unreadEntries: ?string[],
  entryRatings: EntryRatings,
  context: CanvasContext,
  contextID: string,
  courseName: string,
  canRate: boolean,
  initialPostRequired: boolean,
  groups: GroupsState,
}

const {
  refreshDiscussionEntries,
  refreshSingleDiscussion,
  deleteDiscussionEntry,
  markAllAsRead,
  markEntryAsRead,
  markEntryAsUnread,
  rateEntry,
} = DetailActions
const { deleteDiscussion } = EditActions
const { updateContextPermissions } = PermissionsActions

const Actions = {
  refreshDiscussionEntries,
  refreshSingleDiscussion,
  deleteDiscussion,
  deleteDiscussionEntry,
  markAllAsRead,
  markEntryAsRead,
  markEntryAsUnread,
  updateContextPermissions,
  rateEntry,
}

export type Props
  = State
  & OwnProps
  & RefreshProps
  & typeof Actions
  & NavigationProps
  & AsyncState
  & PushNotificationProps & {
  isAnnouncement?: boolean,
  permissions: { [string]: boolean },
}

export class DiscussionDetails extends Component<Props, any> {
  hasReplaced: boolean = false

  static defaultProps = {
    markTopicAsRead,
  }

  constructor (props: Props) {
    super(props)
    this.state = {
      rootNodePath: [],
      deletePending: false,
      maxReplyNodeDepth: 2,
      unread_entries: props.unreadEntries || [],
      markedUnread: [], // [String] of entry IDs
    }
    const groupDiscussion = this.groupDiscussion(props)
    if (groupDiscussion && this.showingWrongDiscussionForGroups(props)) {
      // We're showing the wrong discussion. Replace with group version.
      const { group_id, id } = groupDiscussion
      this.hasReplaced = true
      this.props.navigator.replace(`/groups/${group_id}/discussion_topics/${id}`)
    } else {
      this.state.flatReplies = this.rootRepliesData(props.discussion, [], this.state.maxReplyNodeDepth, props.entryRatings)
      NativeModules.AppStoreReview.handleNavigateToAssignment()
      if (isStudent) {
        ModuleItemsProgress.viewedDiscussion(props.contextID, props.discussionID)
      }
      props.markTopicAsRead(props.context, props.contextID, props.discussionID)
    }
  }

  componentWillUnmount () {
    if (this.props.discussion) {
      this.props.refreshSingleDiscussion(this.props.context, this.props.contextID, this.props.discussionID)
    }
    NativeModules.AppStoreReview.handleNavigateFromAssignment()
  }

  componentWillReceiveProps (nextProps: Props) {
    const groupDiscussion = this.groupDiscussion(nextProps)
    if (!this.hasReplaced && groupDiscussion && this.showingWrongDiscussionForGroups(nextProps)) {
      // We're showing the wrong discussion. Replace with group version.
      const { group_id, id } = groupDiscussion
      this.hasReplaced = true
      this.props.navigator.replace(`/groups/${group_id}/discussion_topics/${id}`)
      return
    }

    if (nextProps.error && nextProps.error !== this.props.error) {
      alertError(nextProps.error)
    }

    if (this.state.deletePending && !nextProps.pending && !nextProps.error && !nextProps.discussion) {
      this.setState({
        deletePending: false,
        unread_entries: nextProps.unreadEntries,
      })
      this.props.navigator.pop()
      return
    }

    // set unread_entries first because rootRepliesData depends on it
    this.setState({ unread_entries: nextProps.unreadEntries }, () => {
      this.setState({
        flatReplies: this.rootRepliesData(
          nextProps.discussion,
          this.state.rootNodePath,
          this.state.maxReplyNodeDepth,
          nextProps.entryRatings
        ),
      })
    })
  }

  onTraitCollectionChange () {
    this.props.navigator.traitCollection((traits) => { this.traitCollectionDidChange(traits) })
  }

  traitCollectionDidChange (traits: TraitCollection) {
    const maxReplyNodeDepth = isRegularDisplayMode(traits) ? 4 : 2
    this.setState({
      maxReplyNodeDepth,
      flatReplies: this.rootRepliesData(this.props.discussion, this.state.rootNodePath, maxReplyNodeDepth, this.props.entryRatings),
    })
  }

  showingWrongDiscussionForGroups = (props: Props) => {
    const { discussion } = props
    // True if we're not in a group context and this is a group discussion
    return isStudent() &&
      discussion &&
      props.context !== 'groups' &&
      discussion.group_category_id &&
      discussion.group_topic_children
  }

  groupDiscussion = (props: Props) => {
    const { discussion } = props
    if (!discussion || !discussion.group_topic_children) {
      return null
    }
    const groups = Object.keys(props.groups)
    const groupDiscussion = discussion.group_topic_children.find(({ group_id }) => groups.includes(group_id))
    return groupDiscussion
  }

  navigateToContextCard = () => {
    if (this.props.discussion) {
      this.props.navigator.show(
        `/${this.props.context}/${this.props.contextID}/users/${this.props.discussion.author.id}`,
        { modal: true },
      )
    }
  }

  renderDetails = (discussion: Discussion) => {
    const showReplies = discussion.replies?.length > 0
    const points = this._points(discussion)
    let user = discussion.author
    const hasValidDate = discussion.delayed_post_at || discussion.posted_at
    const date = new Date(discussion.delayed_post_at || discussion.posted_at)
    const sections = discussion.sections || []
    const showGroupTopicChildren = isTeacher() &&
      this.props.context === 'courses' &&
      discussion.group_topic_children?.length > 0
    return (
      <View>
        <AssignmentSection isFirstRow={true} style={style.topContainer}>
          <Heading1 testID='DiscussionDetails.titleLabel'>{discussion.title ?? i18n('No Title')}</Heading1>
          { !this.props.isAnnouncement &&
            <View style={style.pointsContainer}>
              {Boolean(points) && <Text testID='DiscussionDetails.pointsLabel' style={style.points}>{points}</Text>}
              {isTeacher() && <PublishedIcon published={discussion.published} />}
            </View>
          }
          { discussion.is_section_specific &&
            <SubTitle style={style.sectionsText}>
              {i18n('Sections: {sections}', {
                sections: sections.map(section => section.name).join(', '),
              })}
            </SubTitle>
          }
        </AssignmentSection>

        { isTeacher() && this.props.assignment &&
          <AssignmentSection
            title={i18n('Due')}
            image={Images.assignments.calendar}
            showDisclosureIndicator={true}
            onPress={this.viewDueDateDetails}
            testID='DiscussionDetails.dueDates'
          >
            <AssignmentDates assignment={this.props.assignment} />
          </AssignmentSection>
        }

        { isTeacher() && this.props.assignment && !showGroupTopicChildren &&
          <AssignmentSection
            title={i18n('Submissions')}
            testID='DiscussionDetails.submissionGraphs'
            onPress={() => this.viewSubmissions()}
            showDisclosureIndicator
          >
            <SubmissionBreakdownGraphSection
              onPress={this.onSubmissionDialPress}
              courseID={this.props.assignment.course_id}
              assignmentID={this.props.assignment.id}
              style={style.submission}
            />
          </AssignmentSection>
        }

        <View style={style.section} >
          <View style={style.authorContainer}>
            { user?.display_name &&
              <Avatar
                testID='DiscussionDetails.avatar'
                height={32}
                key={user.id}
                avatarURL={user.avatar_image_url}
                userName={user.display_name}
                style={style.avatar}
                onPress={this.navigateToContextCard}
              />
            }
            <View style={[style.authorInfoContainer, { marginLeft: (user && user.display_name) ? vars.padding : 0 }]}>
              { user?.display_name && <Text style={style.authorName} testID='DiscussionDetails.authorName'>{personDisplayName(user.display_name, user.pronouns)}</Text> }
              { hasValidDate && <Text style={style.authorDate} testID='DiscussionDetails.postDateLabel'>{i18n("{ date, date, 'MMM d'} at { date, time, short }", { date })}</Text> }
            </View>
          </View>

          <CanvasWebView
            style={{ flex: 1, marginHorizontal: -vars.padding, minHeight: vars.padding }}
            automaticallySetHeight
            html={discussion.message ?? ''}
            navigator={this.props.navigator}
          />
          { discussion.attachments?.length === 1 &&
            // should only ever have 1, blocked by UI, but API returns array of 1 :facepalm:
            <TouchableOpacity
              testID='DiscussionDetails.attachmentButton'
              accessibilityRole='button'
              onPress={this.showAttachment}
            >
              <View style={style.attachment}>
                <Image source={Images.paperclip} style={style.attachmentIcon} />
                <Text style={style.attachmentText}>
                  {discussion.attachments[0].display_name}
                </Text>
              </View>
            </TouchableOpacity>
          }

          {!discussion.locked_for_user && this.props.permissions.post_to_forum &&
            <View style={style.authorContainer}>
              <TouchableHighlight
                underlayColor={colors.backgroundLightest}
                onPress={this._onPressReply}
                testID='DiscussionDetails.replyButton'
                accessibilityRole='button'
              >
                <View style={style.replyButtonWrapper}>
                  <Image
                    source={icon('reply')}
                    style={style.replyButtonImage}
                  />
                  <Text style={style.reply}>{i18n('Reply')}</Text>
                </View>
              </TouchableHighlight>
            </View>
          }
        </View>

        { showGroupTopicChildren &&
            <View style={style.section}>
              <GroupTopicChildren
                courseID={this.props.contextID}
                courseColor={this.props.courseColor}
                topicChildren={discussion.group_topic_children}
                navigator={this.props.navigator}
              />
            </View>
        }

        { showReplies && this.state.rootNodePath.length === 0 &&
          <AssignmentSection style={{ paddingBottom: 0 }}>
            <Heading1 testID='DiscussionDetails.repliesHeading'>{i18n('Replies')}</Heading1>
          </AssignmentSection>
        }

        { showReplies && this.renderPopReplyStackButton() }

        { this.props.initialPostRequired &&
          <AssignmentSection>
            <Text testID='discussions.details.require_initial_post.message'>
              {i18n('Replies are only visible to those who have posted at least one reply.')}
            </Text>
          </AssignmentSection>
        }
      </View>
    )
  }

  renderPopReplyStackButton = () => {
    if (this.state.rootNodePath.length !== 0) {
      return (
        <AssignmentSection style={{ paddingBottom: 0 }}>
          <TouchableHighlight testID='discussion.popToLastDiscussionList'
            accessibilityLabel={i18n('Back to replies')}
            accessible={true}
            accessibilityRole='button'
            onPress={this._onPopReplyRootPath}
            underlayColor={colors.backgroundLightest}>
            <View style={style.popReplyStackContainer}>
              <Image source={Images.backIcon} style={style.popReplyStackIcon}/>
              <Text style={{ paddingLeft: 5, color: colors.linkColor }}>{i18n('Back')}</Text>
            </View>
          </TouchableHighlight>
        </AssignmentSection>
      )
    } else return (<View/>)
  }

  renderReply = ({ item, index }: { item: any, index: number }) => {
    const discussion = this.props.discussion || {}
    const reply = item
    let participants = discussion && discussion.participants || []
    let path = (this.state.rootNodePath.length > 1) ? this.state.rootNodePath.concat(reply.myPath.slice(1, reply.myPath.length)) : reply.myPath
    const discussionLockedForUser = discussion.locked_for_user

    return (
      <View style={style.row}>
        <Reply
          maxReplyNodeDepth={this.state.maxReplyNodeDepth}
          deleteDiscussionEntry={this._confirmDeleteReply}
          replyToEntry={this._onPressReplyToEntry}
          navigator={this.props.navigator}
          context={this.props.context}
          contextID={this.props.contextID}
          discussionID={discussion.id}
          reply={reply}
          readState={reply.readState}
          depth={reply.depth}
          myPath={path}
          participants={participants}
          onPressMoreReplies={this._onPressMoreReplies}
          isRootReply
          discussionLockedForUser={discussionLockedForUser}
          userCanReply={this.props.permissions.post_to_forum}
          rating={reply.rating}
          canRate={this.props.canRate}
          showRating={discussion.allow_rating}
          isLastReply={this.state.flatReplies.length - 1 === index}
          isAnnouncement={Boolean(this.props.isAnnouncement)}
          rateEntry={this.props.rateEntry}
          onMarkUnread={this.markEntryAsUnread}
          markEntryAsRead={this.props.markEntryAsRead}
        />
      </View>
    )
  }

  markEntryAsUnread = (entryID) => {
    const { context, contextID, discussionID } = this.props
    this.props.markEntryAsUnread(context, contextID, discussionID, entryID)
    this.setState({ markedUnread: [ ...this.state.markedUnread, entryID ] })
  }

  rootRepliesData = (discussion: ?Discussion, rootNodePath: number[], maxDepth: number, entryRatings: EntryRatings) => {
    if (!discussion) return []
    let replies = discussion && discussion.replies || []

    if (rootNodePath.length === 0) return this.flattenRepliesData([], 0, replies, [], maxDepth, entryRatings)

    let reply = replyFromLocalIndexPath(rootNodePath, replies, false)
    if (reply) {
      return this.flattenRepliesData([], 0, [reply], [], maxDepth, entryRatings)
    } else {
      return [reply]
    }
  }

  flattenRepliesData (flatList: DiscussionReply[], depth: number, replies: DiscussionReply[], indexPath: number[], maxDepth: number, entryRatings: EntryRatings = {}): DiscussionReply[] {
    if (!replies || depth > maxDepth) return flatList

    for (let i = 0; i < replies.length; i++) {
      const readState = this.checkReadState(replies[i].id)
      const reply = {
        ...replies[i],
        depth: depth,
        myPath: [...indexPath, i],
        readState: readState,
        rating: entryRatings[replies[i].id],
      }
      flatList.push(reply)
      flatList = this.flattenRepliesData(flatList, depth + 1, replies[i].replies, reply.myPath, maxDepth, entryRatings)
    }
    return flatList
  }

  render () {
    return (
      <Screen
        onTraitCollectionChange={this.onTraitCollectionChange.bind(this)}
        title={this.props.isAnnouncement ? i18n('Announcement Details') : i18n('Discussion Details')}
        navBarColor={this.props.courseColor}
        navBarStyle='context'
        rightBarButtons={ isTeacher() && [
          {
            image: Images.kabob,
            testID: 'DiscussionDetails.editButton',
            accessibilityLabel: i18n('Options'),
            action: this.showEditActionSheet,
          },
        ]}
        subtitle={this.props.courseName}>
        <View style={style.sectionListContainer}>
          <FlatList
            refreshing={this.props.refreshing}
            onRefresh={this.props.refresh}
            ListHeaderComponent={this.props.discussion ? this.renderDetails(this.props.discussion) : null}
            data={this.state.flatReplies}
            renderItem={this.renderReply}
            onViewableItemsChanged={this._markViewableAsRead}
            initialNumToRender={10}
            extraData={{
              unread_entries: this.state.unread_entries,
            }}
            keyExtractor={this.keyExtractor}
            windowSize={5}
          />
        </View>
      </Screen>
    )
  }

  keyExtractor = (item: Object, index: number) => `${index}`

  showEditActionSheet = () => {
    ActionSheetIOS.showActionSheetWithOptions(
      {
        options: [i18n('Edit'), i18n('Mark All as Read'), i18n('Delete'), i18n('Cancel')],
        destructiveButtonIndex: 2,
        cancelButtonIndex: 3,
      },
      this._editActionSheetSelected,
    )
  }

  _editActionSheetSelected = (index: number) => {
    switch (index) {
      case 0:
        this._editDiscussion()
        break
      case 1:
        this.props.markAllAsRead(
          this.props.context,
          this.props.contextID,
          this.props.discussionID,
          this.props.discussion && this.props.discussion.unread_count
        )
        break
      case 2:
        this._confirmDeleteDiscussion()
        break
    }
  }

  _confirmDeleteDiscussion = () => {
    const alertTitle = this.props.isAnnouncement ? i18n('Are you sure you want to delete this announcement?') : i18n('Are you sure you want to delete this discussion?')
    Alert.alert(
      alertTitle,
      null,
      [
        { text: i18n('Cancel'), style: 'cancel' },
        { text: i18n('OK'), onPress: this._deleteDiscussion },
      ],
    )
  }

  _confirmDeleteReply = (...args) => {
    Alert.alert(
      i18n('Are you sure you want to delete this reply?'),
      null,
      [
        { text: i18n('Cancel'), style: 'cancel' },
        { text: i18n('OK'), onPress: () => { this.props.deleteDiscussionEntry(...args) } },
      ],
    )
  }

  viewDueDateDetails = () => {
    // $FlowFixMe
    const route = `/courses/${this.props.contextID}/assignments/${this.props.assignment.id}/due_dates`
    this.props.navigator.show(route, { modal: false }, {
      onEditPressed: this._editDiscussion,
    })
  }

  onSubmissionDialPress = (type: string) => {
    this.viewSubmissions(type)
  }

  viewSubmissions = (filterType: ?string) => {
    const { assignment } = this.props
    if (!assignment) return
    if (filterType) {
      this.props.navigator.show(`/courses/${assignment.course_id}/assignments/${assignment.id}/submissions`, { modal: false }, { filterType })
    } else {
      this.props.navigator.show(`/courses/${assignment.course_id}/assignments/${assignment.id}/submissions`)
    }
  }

  viewAllSubmissions = () => {
    this.viewSubmissions()
  }

  showAttachment = () => {
    const discussion = this.props.discussion
    if (discussion && discussion.attachments) {
      this.props.navigator.show('/attachment', { modal: true }, {
        attachment: discussion.attachments[0],
      })
    }
  }

  _points = (discussion: Discussion) => {
    if (discussion.assignment) {
      const pointsPossible = !!discussion.assignment.points_possible &&
        i18n(`{
          count, plural,
          one {# pt}
          other {# pts}
        }`
        , { count: discussion.assignment.points_possible })
      return pointsPossible
    }
  }

  _onPressMoreReplies = (rootPath: number[]) => {
    this.setState({
      rootNodePath: rootPath,
      flatReplies: this.rootRepliesData(this.props.discussion, rootPath, this.state.maxReplyNodeDepth, this.props.entryRatings),
    })

    setTimeout(function () { NativeAccessibility.focusElement('discussion.popToLastDiscussionList') }, 500)
  }

  _onPopReplyRootPath = () => {
    let path = this.state.rootNodePath.slice(0, this.state.rootNodePath.length - this.state.maxReplyNodeDepth)
    if (path.length === 1) path = []
    this.setState({
      rootNodePath: path,
      flatReplies: this.rootRepliesData(this.props.discussion, path, this.state.maxReplyNodeDepth, this.props.entryRatings),
    })
  }

  _onPressReply = () => {
    let lastReplyAt = this.props.discussion && this.props.discussion.last_reply_at
    let permissions = this.props.discussion && this.props.discussion.permissions
    if (this.props.isAnnouncement) {
      logEvent('announcement_replied', { nested: false })
    } else {
      logEvent('discussion_topic_replied', { nested: false })
    }
    this.props.navigator.show(`/${this.props.context}/${this.props.contextID}/discussion_topics/${this.props.discussionID}/reply`, { modal: true, disableSwipeDownToDismissModal: true }, { indexPath: [], lastReplyAt, permissions })
  }

  _onPressReplyToEntry = (entryID: string, indexPath: number[]) => {
    let lastReplyAt = this.props.discussion && this.props.discussion.last_reply_at
    let permissions = this.props.discussion && this.props.discussion.permissions
    this.props.navigator.show(`/${this.props.context}/${this.props.contextID}/discussion_topics/${this.props.discussionID}/entries/${entryID}/replies`, { modal: true, disableSwipeDownToDismissModal: true }, { indexPath: indexPath, entryID, lastReplyAt, permissions })
  }

  _editDiscussion = () => {
    if (this.props.isAnnouncement) {
      this._editAnnouncement()
      return
    }
    this.props.navigator.show(`/${this.props.context}/${this.props.contextID}/discussion_topics/${this.props.discussionID}/edit`, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  _editAnnouncement = () => {
    this.props.navigator.show(`/${this.props.context}/${this.props.contextID}/announcements/${this.props.discussionID}/edit`, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  _deleteDiscussion = () => {
    this.setState({ deletePending: true })
    this.props.deleteDiscussion(this.props.context, this.props.contextID, this.props.discussionID)
  }

  checkReadState (id: string) {
    let unread = new Set(this.state.unread_entries)
    return (unread.has(id)) ? 'unread' : 'read'
  }

  _markViewableAsRead = (info) => {
    setTimeout(() => {
      let dID = this.props.discussionID
      let inView = info.viewableItems
      let unread = [...this.state.unread_entries] || []
      let update = false
      for (let i = 0; i < inView.length; i++) {
        if (inView[i].index !== null && inView[i].isViewable) {
          let reply = inView[i].item
          if (reply.id === dID) { continue }
          let markedUnread = this.state.markedUnread.includes(reply.id)
          if (this.checkReadState(reply.id) === 'unread' && !markedUnread) {
            update = true
            let index = unread.indexOf(reply.id)
            if (index > -1) unread.splice(index, 1)
            if (this.props.discussion) {
              this.props.markEntryAsRead(this.props.context, this.props.contextID, dID, reply.id)
            }
          }
        }
      }
      if (update) this.setState({ unread_entries: unread })
    }, 1000)
  }
}

const style = createStyleSheet((colors, vars) => ({
  sectionListContainer: {
    flex: 1,
  },
  authorContainer: {
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'center',
  },
  authorInfoContainer: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'flex-start',
    alignItems: 'flex-start',
  },
  avatar: { marginTop: vars.padding },
  authorName: {
    fontSize: 14,
    fontWeight: '600',
  },
  authorDate: {
    fontSize: 12,
    color: colors.textDark,
  },
  topContainer: {
    paddingTop: 14,
    paddingLeft: vars.padding,
    paddingRight: vars.padding,
    paddingBottom: 17,
  },
  pointsContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 2,
  },
  points: {
    fontWeight: '500',
    color: colors.textDark,
    marginRight: 14,
  },
  reply: {
    color: colors.buttonPrimaryText,
    fontSize: 14,
    marginLeft: 4,
    fontWeight: '500',
  },
  replyButtonImage: {
    width: 18,
    height: 18,
    resizeMode: 'contain',
    tintColor: colors.buttonPrimaryText,
    marginRight: 6,
  },
  replyButtonWrapper: {
    backgroundColor: colors.buttonPrimaryBackground,
    flexDirection: 'row',
    paddingHorizontal: 16,
    paddingVertical: 10,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 4,
  },
  submission: {
    marginRight: 40,
    marginTop: vars.padding / 2,
  },
  attachment: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: vars.padding,
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
  popReplyStackContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: vars.padding / 2,
  },
  popReplyStackIcon: {
    tintColor: colors.linkColor,
  },
  section: {
    flex: 1,
    paddingTop: vars.padding,
    paddingRight: vars.padding,
    paddingBottom: vars.padding,
    paddingLeft: vars.padding,
    backgroundColor: colors.backgroundLightest,
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
  },
  row: {
    flex: 1,
    flexDirection: 'row',
    paddingHorizontal: vars.padding,
  },
  sectionsText: {
    marginTop: 8,
  },
}))

export function mapStateToProps ({ entities }: AppState, ownProps: OwnProps): State {
  const contextID = ownProps.contextID
  const context = ownProps.context
  const discussionID = ownProps.announcementID || ownProps.discussionID
  let isAnnouncement = ownProps.isAnnouncement || ownProps.announcementID != null
  let discussion: ?Discussion
  let pending = 0
  let error = null
  let courseColor
  let courseName = ''
  let unreadEntries = []
  let entryRatings = {}
  let course: ?Course
  let initialPostRequired = true
  let permissions = {}

  if (entities && entities.discussions) {
    if (context === 'courses' && entities.courses[contextID]) {
      const entity = entities.courses[contextID]
      course = entities.courses[contextID].course
      courseColor = entity.color
      courseName = course.name
      permissions = entity.permissions
    } else if (entities.groups[contextID]) {
      let group = entities.groups[contextID]
      courseName = group.group.name
      courseColor = group.color
      permissions = group.permissions
    }
  }

  if (entities.discussions &&
    entities.discussions[discussionID] &&
    entities.discussions[discussionID].data) {
    const state = entities.discussions[discussionID]
    discussion = state.data
    unreadEntries = state.unread_entries || []
    entryRatings = state.entry_ratings || {}
    pending = state.pending
    error = state.error
    initialPostRequired = state.initialPostRequired ? discussion.require_initial_post : false
    if (!isAnnouncement) {
      isAnnouncement = state.isAnnouncement
    }
  }

  let assignment = null
  if (discussion && discussion.assignment_id) {
    let entity = entities.assignments[discussion.assignment_id]
    assignment = entity ? entity.data : null
  }

  let canRate = false
  if (discussion) {
    if (discussion.allow_rating) {
      if (discussion.only_graders_can_rate) {
        const graders = ['teacher', 'teacherenrollment', 'ta']
        canRate = Boolean(course && course.enrollments && course.enrollments.some(e => graders.includes(e.type.toLowerCase())))
      } else {
        canRate = true
      }
    }
  }

  return {
    discussion,
    unreadEntries,
    entryRatings,
    pending,
    error,
    context,
    contextID,
    discussionID,
    courseName,
    courseColor,
    assignment,
    isAnnouncement,
    canRate,
    initialPostRequired,
    groups: entities.groups,
    permissions,
  }
}

export function shouldRefresh (props: Props): boolean {
  return !props.discussion ||
         !props.discussion.replies ||
         (props.discussion.assignment_id && !props.assignment) ||
         (!props.unreadEntries && props.discussion.unread_count > 0) ||
         props.discussion.allow_rating ||
         Object.keys(props.permissions).length === 0
}

export function refreshData (props: Props): void {
  props.refreshDiscussionEntries(props.context, props.contextID, props.discussionID, true)

  // Must refresh single discussion in case user cant view replies.
  props.refreshSingleDiscussion(props.context, props.contextID, props.discussionID)

  props.updateContextPermissions(props.context, props.contextID)
}

let Refreshed = refresh(
  refreshData,
  shouldRefresh,
  props => Boolean(props.pending)
)(DiscussionDetails)
let Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<Props, any>)
