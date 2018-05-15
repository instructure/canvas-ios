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
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  TouchableHighlight,
  Image,
  FlatList,
  ActionSheetIOS,
  AlertIOS,
  NativeModules,
} from 'react-native'
import i18n from 'format-message'
import DetailActions from './actions'
import EditActions from '../edit/actions'
import AssignmentSection from '../../assignment-details/components/AssignmentSection'
import AssignmentDates from '../../assignment-details/components/AssignmentDates'
import CanvasWebView from '../../../common/components/CanvasWebView'
import Avatar from '../../../common/components/Avatar'
import PublishedIcon from '../../assignment-details/components/PublishedIcon'
import SubmissionBreakdownGraphSection from '../../assignment-details/components/SubmissionBreakdownGraphSection'
import Images from '../../../images'
import {
  Heading1,
  Text,
  SubTitle,
  BOLD_FONT,
} from '../../../common/text'
import colors from '../../../common/colors'
import refresh from '../../../utils/refresh'
import Screen from '../../../routing/Screen'
import Reply from './Reply'
import { replyFromLocalIndexPath } from '../reducer'
import { type TraitCollection } from '../../../routing/Navigator'
import { isRegularDisplayMode } from '../../../routing/utils'
import { isTeacher } from '../../app'
import { alertError } from '../../../redux/middleware/error-handler'

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
  entryRatings: { [string]: number },
  context: CanvasContext,
  contextID: string,
  courseName: string,
  canRate: boolean,
  initialPostRequired: boolean,
}

type ViewableReply = {
  index: number,
  isViewable: boolean,
  key: string,
  item: DiscussionReply,
}

const {
  refreshDiscussionEntries,
  refreshSingleDiscussion,
  deleteDiscussionEntry,
  markAllAsRead,
  markEntryAsRead,
} = DetailActions
const { NativeAccessibility } = NativeModules
const { deleteDiscussion } = EditActions

const Actions = {
  refreshDiscussionEntries,
  refreshSingleDiscussion,
  deleteDiscussion,
  deleteDiscussionEntry,
  markAllAsRead,
  markEntryAsRead,
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
}

export class DiscussionDetails extends Component<Props, any> {
  constructor (props: Props) {
    super(props)
    this.state = {
      rootNodePath: [],
      deletePending: false,
      maxReplyNodeDepth: 2,
      unread_entries: props.unreadEntries || [],
      entry_ratings: props.entryRatings || {},
    }
    this.state.flatReplies = this.rootRepliesData(props.discussion, [], this.state.maxReplyNodeDepth)
  }

  componentWillUnmount () {
    if (this.props.discussion) {
      this.props.refreshSingleDiscussion(this.props.context, this.props.contextID, this.props.discussionID)
    }
  }

  componentWillReceiveProps (nextProps: Props) {
    if (nextProps.error && nextProps.error !== this.props.error) {
      alertError(nextProps.error)
    }

    if (this.state.deletePending && !nextProps.pending && !nextProps.error && !nextProps.discussion) {
      this.setState({
        deletePending: false,
        unread_entries: nextProps.unreadEntries,
        entry_ratings: nextProps.entryRatings || {},
      })
      this.props.navigator.pop()
      return
    }
    this.setState({
      unread_entries: nextProps.unreadEntries,
      entry_ratings: nextProps.entryRatings || {},
      flatReplies: this.rootRepliesData(nextProps.discussion, this.state.rootNodePath, this.state.maxReplyNodeDepth),
    })
  }

  onTraitCollectionChange () {
    this.props.navigator.traitCollection((traits) => { this.traitCollectionDidChange(traits) })
  }

  traitCollectionDidChange (traits: TraitCollection) {
    const maxReplyNodeDepth = isRegularDisplayMode(traits) ? 4 : 2
    this.setState({
      maxReplyNodeDepth,
      flatReplies: this.rootRepliesData(this.props.discussion, this.state.rootNodePath, maxReplyNodeDepth),
    })
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
    const showReplies = discussion.replies && discussion.replies.length > 0
    const points = this._points(discussion)
    let user = discussion.author
    const assignmentID = this.props.assignment ? this.props.assignment.id : null
    const date = new Date(discussion.delayed_post_at || discussion.posted_at)
    const sections = discussion.sections || []
    return (
      <View>
        <AssignmentSection isFirstRow={true} style={style.topContainer}>
          <Heading1>{discussion.title || i18n('No Title')}</Heading1>
          { !this.props.isAnnouncement &&
            <View style={style.pointsContainer}>
              {Boolean(points) && <Text style={style.points}>{points}</Text>}
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
          >
            <AssignmentDates assignment={this.props.assignment} />
          </AssignmentSection>
        }

        { isTeacher() && assignmentID &&
          <AssignmentSection
            title={i18n('Submissions')}
            testID='discussions.submission-graphs'
            onPress={() => this.viewSubmissions()}
            showDisclosureIndicator
          >
            <SubmissionBreakdownGraphSection onPress={this.onSubmissionDialPress} courseID={this.props.contextID} assignmentID={assignmentID} style={style.submission}/>
          </AssignmentSection>
        }

        <View style={style.section} >
          <View style={style.authorContainer}>
            { user && user.display_name &&
              <Avatar
                testID='discussion.details.avatar'
                height={32}
                key={user.id}
                avatarURL={user.avatar_image_url}
                userName={user.display_name}
                style={style.avatar}
                onPress={this.navigateToContextCard}
              />
            }
            <View style={[style.authorInfoContainer, { marginLeft: (user && user.display_name) ? global.style.defaultPadding : 0 }]}>
              { user && user.display_name && <Text style={style.authorName}>{user.display_name}</Text> }
              <Text style={style.authorDate} testID='discussion.details.post-date-lbl'>{i18n("{ date, date, 'MMM d'} at { date, time, short }", { date })}</Text>
            </View>
          </View>

          { (Boolean(discussion.message) || Boolean(discussion.attachments)) &&
            <View style={style.message}>
              { Boolean(discussion.message) &&
                <CanvasWebView style={{ flex: 1 }} automaticallySetHeight html={discussion.message} navigator={this.props.navigator} />
              }
              { Boolean(discussion.attachments) && discussion.attachments && discussion.attachments.length === 1 &&
                // should only ever have 1, blocked by UI, but API returns array of 1 :facepalm:
                <TouchableHighlight testID={`discussion.${discussion.id}.attachment`} onPress={this.showAttachment}>
                  <View style={style.attachment}>
                    <Image source={Images.attachment} style={style.attachmentIcon} />
                    <Text style={style.attachmentText}>
                      {discussion.attachments[0].display_name}
                    </Text>
                  </View>
                </TouchableHighlight>
              }
            </View>
          }

          {!discussion.locked_for_user &&
            <View style={style.authorContainer}>
              <TouchableHighlight
                underlayColor='white'
                onPress={this._onPressReply}
                testID='discussion-reply'
                accessibilityTraits='button'
              >
                <View style={[{ backgroundColor: colors.primaryButtonColor }, style.replyButtonWrapper]}>
                  <Image source={Images.rce.undo} style={style.replyButtonImage} />
                  <Text style={[{ color: colors.primaryButtonTextColor }, style.reply]}>{i18n('Reply')}</Text>
                </View>
              </TouchableHighlight>
            </View>
          }
        </View>

        { showReplies && this.state.rootNodePath.length === 0 &&
          <AssignmentSection style={{ paddingBottom: 0 }}>
            <Heading1>{i18n('Replies')}</Heading1>
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
          <TouchableHighlight testID={`discussion.popToLastDiscussionList`}
            accessibilityLabel={i18n('Back to replies')}
            accessible={true}
            accessibilityTraits={['button']}
            onPress={this._onPopReplyRootPath}
            underlayColor='white'>
            <View style={style.popReplyStackContainer}>
              <Image source={Images.backIcon} style={style.popReplyStackIcon}/>
              <Text style={{ paddingLeft: 5, color: colors.link }}>{i18n('Back')}</Text>
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
          // $FlowFixMe
          participants={participants}
          onPressMoreReplies={this._onPressMoreReplies}
          isRootReply
          discussionLockedForUser={discussionLockedForUser}
          rating={reply.rating}
          canRate={this.props.canRate}
          showRating={discussion.allow_rating}
          isLastReply={this.state.flatReplies.length - 1 === index}
        />
      </View>
    )
  }

  rootRepliesData = (discussion: ?Discussion, rootNodePath: number[], maxDepth: number) => {
    if (!discussion) return []
    let replies = discussion && discussion.replies || []

    if (rootNodePath.length === 0) return this.flattenRepliesData([], 0, replies, [], maxDepth)

    let reply = replyFromLocalIndexPath(rootNodePath, replies, false)
    if (reply) {
      return this.flattenRepliesData([], 0, [reply], [], maxDepth)
    } else {
      return [reply]
    }
  }

  flattenRepliesData (flatList: DiscussionReply[], depth: number, replies: DiscussionReply[], indexPath: number[], maxDepth: number): DiscussionReply[] {
    if (!replies || depth > maxDepth) return flatList

    for (let i = 0; i < replies.length; i++) {
      const readState = this.checkReadState(replies[i].id)
      const reply = {
        ...replies[i],
        depth: depth,
        myPath: [...indexPath, i],
        readState: readState,
        rating: this.state.entry_ratings[replies[i].id],
      }
      flatList.push(reply)
      flatList = this.flattenRepliesData(flatList, depth + 1, replies[i].replies, reply.myPath, maxDepth)
    }
    return flatList
  }

  render () {
    return (
      <Screen
        onTraitCollectionChange={this.onTraitCollectionChange.bind(this)}
        title={this.props.isAnnouncement ? i18n('Announcement Details') : i18n('Discussion Details')}
        navBarColor={this.props.courseColor}
        navBarStyle='dark'
        rightBarButtons={ isTeacher() && [
          {
            image: Images.kabob,
            testID: 'discussions.details.edit.button',
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
              entry_ratings: this.state.entry_ratings,
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
    AlertIOS.alert(
      alertTitle,
      null,
      [
        { text: i18n('Cancel'), style: 'cancel' },
        { text: i18n('OK'), onPress: this._deleteDiscussion },
      ],
    )
  }

  _confirmDeleteReply = (...args) => {
    AlertIOS.alert(
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
    const { contextID, assignment } = this.props
    if (!assignment) return
    if (filterType) {
      this.props.navigator.show(`/courses/${contextID}/assignments/${assignment.id}/submissions`, { modal: false }, { filterType })
    } else {
      this.props.navigator.show(`/courses/${contextID}/assignments/${assignment.id}/submissions`)
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
      flatReplies: this.rootRepliesData(this.props.discussion, rootPath, this.state.maxReplyNodeDepth),
    })

    setTimeout(function () { NativeAccessibility.focusElement('discussion.popToLastDiscussionList') }, 500)
  }

  _onPopReplyRootPath = () => {
    let path = this.state.rootNodePath.slice(0, this.state.rootNodePath.length - this.state.maxReplyNodeDepth)
    if (path.length === 1) path = []
    this.setState({
      rootNodePath: path,
      flatReplies: this.rootRepliesData(this.props.discussion, path, this.state.maxReplyNodeDepth),
    })
  }

  _onPressReply = () => {
    let lastReplyAt = this.props.discussion && this.props.discussion.last_reply_at
    let permissions = this.props.discussion && this.props.discussion.permissions
    this.props.navigator.show(`/${this.props.context}/${this.props.contextID}/discussion_topics/${this.props.discussionID}/reply`, { modal: true }, { indexPath: [], lastReplyAt, permissions })
  }

  _onPressReplyToEntry = (entryID: string, indexPath: number[]) => {
    let lastReplyAt = this.props.discussion && this.props.discussion.last_reply_at
    let permissions = this.props.discussion && this.props.discussion.permissions
    this.props.navigator.show(`/${this.props.context}/${this.props.contextID}/discussion_topics/${this.props.discussionID}/entries/${entryID}/replies`, { modal: true }, { indexPath: indexPath, entryID, lastReplyAt, permissions })
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

  _markViewableAsRead = (info: { viewableItems: Array<ViewableReply>, changed: Array<ViewableReply>}) => {
    requestIdleCallback(() => {
      let dID = this.props.discussionID
      let inView = info.viewableItems
      let unread = [...this.state.unread_entries] || []
      let update = false
      for (let i = 0; i < inView.length; i++) {
        if (inView[i].index !== null && inView[i].isViewable) {
          let reply = inView[i].item
          if (reply.id === dID) { continue }
          if (this.checkReadState(reply.id) === 'unread') {
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
    })
  }
}

const style = StyleSheet.create({
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
  avatar: { marginTop: global.style.defaultPadding },
  authorName: {
    fontSize: 14,
    fontWeight: '600',
  },
  authorDate: {
    fontSize: 12,
    color: colors.grey5,
  },
  topContainer: {
    paddingTop: 14,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
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
    color: colors.grey4,
    marginRight: 14,
  },
  reply: {
    color: 'white',
    fontSize: 14,
    marginLeft: 4,
    fontWeight: '500',
  },
  replyButtonImage: {
    width: 18,
    height: 18,
    resizeMode: 'contain',
    tintColor: colors.primaryButtonTextColor,
    marginRight: 6,
  },
  replyButtonWrapper: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    paddingVertical: 10,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 4,
  },
  submission: {
    marginRight: 40,
    marginTop: global.style.defaultPadding / 2,
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
  popReplyStackContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: global.style.defaultPadding / 2,
  },
  popReplyStackIcon: {
    tintColor: colors.link,
  },
  message: {
    paddingTop: global.style.defaultPadding,
    paddingBottom: global.style.defaultPadding,
  },
  section: {
    flex: 1,
    paddingTop: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
    paddingBottom: global.style.defaultPadding,
    paddingLeft: global.style.defaultPadding,
    backgroundColor: 'white',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.grey2,
  },
  row: {
    flex: 1,
    flexDirection: 'row',
    paddingHorizontal: global.style.defaultPadding,
  },
  sectionsText: {
    marginTop: 8,
  },
})

export function mapStateToProps ({ entities }: AppState, ownProps: OwnProps): State {
  const contextID = ownProps.contextID
  const context = ownProps.context
  const discussionID = ownProps.announcementID || ownProps.discussionID
  const isAnnouncement = ownProps.isAnnouncement || ownProps.announcementID != null
  let discussion: ?Discussion
  let pending = 0
  let error = null
  let courseColor
  let courseName = ''
  let unreadEntries = []
  let entryRatings = {}
  let course: ?Course
  let initialPostRequired = true

  if (entities && entities.discussions) {
    if (context === 'courses' && entities.courses[contextID]) {
      const entity = entities.courses[contextID]
      course = entities.courses[contextID].course
      courseColor = entity.color
      courseName = course.name
    } else if (entities.groups[contextID]) {
      let group = entities.groups[contextID]
      courseName = group.group.name
      courseColor = group.color
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
  }
}

export function shouldRefresh (props: Props): boolean {
  return !props.discussion ||
         !props.discussion.replies ||
         (props.discussion.assignment_id && !props.assignment) ||
         (!props.unreadEntries && props.discussion.unread_count > 0) ||
         props.discussion.allow_rating
}

export function refreshData (props: Props): void {
  props.refreshDiscussionEntries(props.context, props.contextID, props.discussionID, true)

  // Must refresh single discussion in case user cant view replies.
  props.refreshSingleDiscussion(props.context, props.contextID, props.discussionID)
}

let Refreshed = refresh(
  //  TODO - add deep link ability to refreshDiscussion without entry from discussion list
  refreshData,
  shouldRefresh,
  props => Boolean(props.pending)
)(DiscussionDetails)
let Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<Props, any>)
