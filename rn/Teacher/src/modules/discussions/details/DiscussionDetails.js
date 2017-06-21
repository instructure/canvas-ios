/* @flow */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  TouchableHighlight,
  Image,
  SectionList,
} from 'react-native'
import i18n from 'format-message'
import Actions from './actions'
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
import Navigator from '../../../routing/Navigator'
import DiscussionReplies from './DiscussionReplies'

type OwnProps = {
  discussionID: string,
  courseID: string,
}

type State = {
  discussion: ?Discussion,
}

export type Props = State & OwnProps & RefreshProps & Actions & {
  navigator: Navigator,
  isAnnouncement?: boolean,
}

export class DiscussionDetails extends Component<any, Props, any> {
  renderDetails = ({ item, index }: { item: Discussion, index: number }) => {
    const discussion = item
    const points = this._points(discussion)
    let user = discussion.author
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

        {discussion.assignment && <AssignmentSection
          title={i18n('Due')}
          image={Images.assignments.calendar}
          showDisclosureIndicator={true}
          onPress={this.viewDueDateDetails} >
          <AssignmentDates assignment={discussion.assignment} />
        </AssignmentSection>}

        {discussion.assignment && <AssignmentSection
          title={i18n('Submissions')}
          testID='discussions.submission-graphs'
          onPress={() => this.viewSubmissions()}
          showDisclosureIndicator>
          <SubmissionBreakdownGraphSection onPress={this.onSubmissionDialPress} courseID={this.props.courseID} assignmentID={discussion.assignment.id} style={style.submission}/>
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

  renderReply = (discussion: ?Discussion) => ({ item, index }: { item: DiscussionReply, index: number }) => {
    const reply = item
    let participants = discussion && discussion.participants || []
    return (
      <View>
        <DiscussionReplies reply={reply} participants={participants} navigator={this.props.navigator}/>
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
        navBarColor={this.props.course.color}
        navBarStyle='dark'
        rightBarButtons={[
          {
            title: i18n('Edit'),
            testID: 'discussions.details.edit.button',
            action: this._editDiscussion,
          },
        ]}
        subtitle={this.props.course.name}>
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

  editAssignment = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/assignments/${this.props.assignment.id}/edit`, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  viewDueDateDetails = () => {
    const route = `/courses/${this.props.courseID}/assignments/${this.props.assignment.id}/due_dates`
    this.props.navigator.show(route, { modal: false }, {
      onEditPressed: this.editAssignment,
    })
  }

  onSubmissionDialPress = (type: string) => {
    this.viewSubmissions(type)
  }

  viewSubmissions = (filterType: ?string) => {
    const { courseID, assignment } = this.props
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
    if (this.props.discussion.attachments && this.props.discussion.attachments.length === 1) {
      this.props.navigator.show('/attachment', { modal: true }, {
        attachment: this.props.discussion.attachments[0],
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
    this.props.navigator.show(`/courses/${this.props.courseID}/discussion_topics/${this.props.discussionID}/reply`, { modal: true })
  }

  _editDiscussion = () => {
    if (this.props.isAnnouncement) {
      this._editAnnouncement()
      return
    }
    this.props.navigator.show(`/courses/${this.props.courseID}/discussion_topics/${this.props.discussion.id}/edit`, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  _editAnnouncement = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/announcements/${this.props.discussion.id}/edit`, { modal: true, modalPresentationStyle: 'formsheet' })
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
  let course = entities.courses[courseID].course

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
    course,
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
