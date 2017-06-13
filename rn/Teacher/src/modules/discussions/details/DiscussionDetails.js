/* @flow */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  TouchableHighlight,
} from 'react-native'
import i18n from 'format-message'
import Actions from './actions'
import { RefreshableScrollView } from '../../../common/components/RefreshableList'
import AssignmentSection from '../../assignment-details/components/AssignmentSection'
import AssignmentDates from '../../assignment-details/components/AssignmentDates'
import WebContainer from '../../../common/components/WebContainer'
import Avatar from '../../../common/components/Avatar'
import { formattedDate } from '../../../utils/dateUtils'
import PublishedIcon from '../../assignment-details/components/PublishedIcon'
import Images from '../../../images'
import {
  Heading1,
  Text,
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
}

export class DiscussionDetails extends Component<any, Props, any> {
  render () {
    const { discussion } = this.props
    let content
    if (!discussion) {
      content = <View />
    } else {
      const points = this._points(discussion)
      let participants = discussion.participants || []
      let user = discussion.author
      content = (
        <RefreshableScrollView
          refreshing={this.props.refreshing}
          onRefresh={this.props.refresh}>
            <AssignmentSection isFirstRow={true} style={style.topContainer}>
              <Heading1>{discussion.title}</Heading1>
              <View style={style.pointsContainer}>
                {points && <Text style={style.points}>{points}</Text>}
                <PublishedIcon published={discussion.published} style={style.publishedIcon} />
              </View>
            </AssignmentSection>

            {discussion.assignment && <AssignmentSection
              title={i18n('Due')}
              image={Images.assignments.calendar} >
              <AssignmentDates assignment={discussion.assignment} />
            </AssignmentSection>}

            {discussion.assignment && <AssignmentSection
              title={i18n('Submissions')}>
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

              { Boolean(discussion.message) &&
                <View style={style.section}>
                  <WebContainer style={{ flex: 1, color: colors.darkText }} scrollEnabled={false} html={discussion.message}/>
                </View>
              }

              <TouchableHighlight>
                <View>
                  <Text style={style.link}>Reply</Text>
                </View>
              </TouchableHighlight>
            </AssignmentSection>

            <AssignmentSection
              title={i18n('Replies')}>
              <DiscussionReplies style={style.replyContainer} replies={discussion.replies} participants={participants}/>
            </AssignmentSection>

        </RefreshableScrollView>
      )
    }

    return (
      <Screen
        title={i18n('Discussion Details')}
        navBarColor={this.props.course.color}
        navBarStyle='dark'
        subtitle={this.props.course.name}>
        {content}
      </Screen>
    )
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
}

const style = StyleSheet.create({
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
  publishedIcon: {
    marginLeft: 14,
  },
  points: {
    fontWeight: '500',
    color: colors.grey4,
  },
  link: {
    color: colors.link,
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

  return {
    discussion,
    pending,
    error,
    courseID,
    discussionID,
    course,
  }
}

let Refreshed = refresh(
  //  TODO - add deep link ability to refreshDiscussion without entry from discussion list
  props => props.refreshDiscussionEntries(props.courseID, props.discussionID),
  props => true,
  props => Boolean(props.pending)
)(DiscussionDetails)
let Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<any, Props, any>)
