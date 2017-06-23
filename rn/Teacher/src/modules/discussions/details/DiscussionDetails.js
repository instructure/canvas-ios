/* @flow */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  TouchableHighlight,
  Image,
  SectionList,
  ActionSheetIOS,
  AlertIOS,
} from 'react-native'
import i18n from 'format-message'
import { default as DetailActions } from './actions'
import { default as EditActions } from '../edit/actions'
import AssignmentSection from '../../assignment-details/components/AssignmentSection'
import AssignmentDates from '../../assignment-details/components/AssignmentDates'
import WebContainer from '../../../common/components/WebContainer'
import Avatar from '../../../common/components/Avatar'
import { formattedDate } from '../../../utils/dateUtils'
import PublishedIcon from '../../assignment-details/components/PublishedIcon'
import SubmissionBreakdownGraphSection from '../../assignment-details/components/SubmissionBreakdownGraphSection'
import Images from '../../../images'
import {
  Heading1,
  Text,
  BOLD_FONT,
} from '../../../common/text'
import colors from '../../../common/colors'
import refresh from '../../../utils/refresh'
import Screen from '../../../routing/Screen'
import DiscussionReplies from './DiscussionReplies'

type OwnProps = {
  discussionID: string,
  courseID: string,
}

type State = {
  discussion: ?Discussion,
  assignment: ?Assignment,
  courseColor: string,
  courseName: string,
}

const { refreshDiscussionEntries, deleteDiscussionEntry } = DetailActions
const { deleteDiscussion } = EditActions

const Actions = {
  refreshDiscussionEntries,
  deleteDiscussion,
  deleteDiscussionEntry,
}

export type Props = State & OwnProps & RefreshProps & typeof Actions & NavigationProps & AsyncState & {
  isAnnouncement?: boolean,
}

export class DiscussionDetails extends Component<any, Props, any> {
  constructor (props: Props) {
    super(props)

    this.state = {
      deletePending: false,
    }
  }

  componentWillReceiveProps (nextProps: Props) {
    if (this.state.deletePending && !nextProps.pending && !nextProps.error && !nextProps.discussion) {
      this.setState({ deletePending: false })
      this.props.navigator.pop()
    }
  }

  renderDetails = ({ item, index }: { item: Discussion, index: number }) => {
    const discussion = item
    const points = this._points(discussion)
    let user = discussion.author
    const assignmentID = this.props.assignment ? this.props.assignment.id : null
    return (
      <View>
        <AssignmentSection isFirstRow={true} style={style.topContainer}>
          <Heading1>{discussion.title}</Heading1>
            { !this.props.isAnnouncement &&
              <View style={style.pointsContainer}>
                {Boolean(points) && <Text style={style.points}>{points}</Text>}
                  <PublishedIcon published={discussion.published} />
              </View>
            }
        </AssignmentSection>

        {this.props.assignment && <AssignmentSection
          title={i18n('Due')}
          image={Images.assignments.calendar}
          showDisclosureIndicator={true}
          onPress={this.viewDueDateDetails} >
          <AssignmentDates assignment={this.props.assignment} />
        </AssignmentSection>}

        {assignmentID && <AssignmentSection
          title={i18n('Submissions')}
          testID='discussions.submission-graphs'
          onPress={() => this.viewSubmissions()}
          showDisclosureIndicator>
          <SubmissionBreakdownGraphSection onPress={this.onSubmissionDialPress} courseID={this.props.courseID} assignmentID={assignmentID} style={style.submission}/>
        </AssignmentSection>}

        <AssignmentSection >
          <View style={style.authorContainer}>
            {user && user.display_name && <Avatar height={32} key={user.id} avatarURL={user.avatar_image_url} userName={user.display_name}
              style={style.avatar}/> }
            <View style={[style.authorInfoContainer, { marginLeft: user.display_name ? global.style.defaultPadding : 0 }]}>
              { user && user.display_name && <Text style={style.authorName}>{user.display_name}</Text> }
                <Text style={style.authorDate}>{formattedDate(discussion.posted_at)}</Text>
            </View>
          </View>

        { (Boolean(discussion.message) || Boolean(discussion.attachments)) &&
           <View style={style.section}>
              { Boolean(discussion.message) &&
                 <WebContainer style={{ flex: 1, color: colors.darkText }} scrollEnabled={false} html={discussion.message}/>
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

          <View style={style.authorContainer}>
            <TouchableHighlight
              underlayColor='white'
              onPress={this._onPressReply}
              testID='discussion-reply'>
                <View style={{ flex: 1, backgroundColor: 'white' }}>
                  <Text style={style.link}>Reply</Text>
                </View>
            </TouchableHighlight>
          </View>
        </AssignmentSection>

        <AssignmentSection
          title={i18n('Replies')}
          style={{ paddingBottom: 0 }}>
        </AssignmentSection>
      </View>
    )
  }

  renderReply = (discussion: Discussion) => ({ item, index }: { item: DiscussionReply, index: number }) => {
    const reply = item
    let participants = discussion && discussion.participants || []

    return (
      <View>
        <DiscussionReplies
        deleteDiscussionEntry={this.props.deleteDiscussionEntry}
        replyToEntry={this._onPressReplyToEntry}
        style={style.replyContainer}
        navigator={this.props.navigator}
        courseID={this.props.courseID}
        discussionID={discussion.id}
        reply={reply}
        pathIndex={index}
        participants={participants}
        />
      </View>
    )
  }

  render () {
    const { discussion } = this.props
    let data = []
    if (discussion) {
      data = [
        { data: [discussion], title: '', renderItem: this.renderDetails },
        { data: discussion.replies || [], title: '', renderItem: this.renderReply(discussion) },
      ]
    }
    return (
      <Screen
        title={this.props.isAnnouncement ? i18n('Announcement Details') : i18n('Discussion Details')}
        navBarColor={this.props.courseColor}
        navBarStyle='dark'
        rightBarButtons={[
          {
            image: Images.kabob,
            testID: 'discussions.details.edit.button',
            action: this.showEditActionSheet,
          },
        ]}
        subtitle={this.props.courseName}>
        <View style={style.sectionListContainer}>
          <SectionList
            refreshing={this.props.refreshing}
            onRefresh={this.props.refresh}
            renderItem={({ item }) => <View/>}
            sections={data}
          />
        </View>
      </Screen>
    )
  }

  showEditActionSheet = () => {
    ActionSheetIOS.showActionSheetWithOptions(
      {
        options: [i18n('Edit'), i18n('Delete'), i18n('Cancel')],
        destructiveButtonIndex: 1,
        cancelButtonIndex: 2,
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
        this._confirmDeleteDiscussion()
        break
    }
  }

  _confirmDeleteDiscussion = () => {
    AlertIOS.alert(
      i18n('Are you sure you want to delete this discussion?'),
      null,
      [
        { text: i18n('Cancel'), style: 'cancel' },
        { text: i18n('OK'), onPress: this._deleteDiscussion },
      ],
    )
  }

  viewDueDateDetails = () => {
    // $FlowFixMe
    const route = `/courses/${this.props.courseID}/assignments/${this.props.assignment.id}/due_dates`
    this.props.navigator.show(route, { modal: false }, {
      onEditPressed: this._editDiscussion,
    })
  }

  onSubmissionDialPress = (type: string) => {
    this.viewSubmissions(type)
  }

  viewSubmissions = (filterType: ?string) => {
    const { courseID, assignment } = this.props
    if (!assignment) return
    if (filterType) {
      this.props.navigator.show(`/courses/${courseID}/assignments/${assignment.id}/submissions`, { modal: false }, { filterType })
    } else {
      this.props.navigator.show(`/courses/${courseID}/assignments/${assignment.id}/submissions`)
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

  _onPressReply = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/discussion_topics/${this.props.discussionID}/reply`, { modal: true }, { parentIndexPath: [] })
  }

  _onPressReplyToEntry = (entryID: string, parentIndexPath: number[]) => {
    this.props.navigator.show(`/courses/${this.props.courseID}/discussion_topics/${this.props.discussionID}/entries/${entryID}/replies`, { modal: true }, { parentIndexPath: parentIndexPath, entryID })
  }

  _editDiscussion = () => {
    if (this.props.isAnnouncement) {
      this._editAnnouncement()
      return
    }
    this.props.navigator.show(`/courses/${this.props.courseID}/discussion_topics/${this.props.discussionID}/edit`, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  _editAnnouncement = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/announcements/${this.props.discussionID}/edit`, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  _deleteDiscussion = () => {
    this.setState({ deletePending: true })
    this.props.deleteDiscussion(this.props.courseID, this.props.discussionID)
  }
}

const style = StyleSheet.create({
  sectionListContainer: {
    flex: 1,
    marginBottom: global.tabBarHeight,
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
    color: colors.grey3,
  },
  topContainer: {
    paddingTop: 14,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
    paddingBottom: 17,
  },
  section: {
    paddingTop: global.style.defaultPadding,
    paddingBottom: global.style.defaultPadding,
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
  link: {
    color: colors.link,
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
})

export function mapStateToProps ({ entities }: AppState, { courseID, discussionID }: OwnProps): State {
  let discussion: ?Discussion
  let pending = 0
  let error = null
  let courseColor = entities.courses[courseID].color
  let courseName = entities.courses[courseID].course.name

  if (entities.discussions &&
    entities.discussions[discussionID] &&
    entities.discussions[discussionID].data) {
    const state = entities.discussions[discussionID]
    discussion = state.data
    pending = state.pending
    error = state.error
  }

  let assignment = null
  if (discussion && discussion.assignment_id) {
    let entity = entities.assignments[discussion.assignment_id]
    assignment = entity ? entity.data : null
  }

  return {
    discussion,
    pending,
    error,
    courseID,
    discussionID,
    courseName,
    courseColor,
    assignment,
  }
}

let Refreshed = refresh(
  //  TODO - add deep link ability to refreshDiscussion without entry from discussion list
  props => props.refreshDiscussionEntries(props.courseID, props.discussionID, true),
  props => !props.discussion || !props.discussion.replies || (props.discussion.assignment_id && !props.assignment),
  props => Boolean(props.pending)
)(DiscussionDetails)
let Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<any, Props, any>)
