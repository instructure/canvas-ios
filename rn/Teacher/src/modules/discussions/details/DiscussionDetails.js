/* @flow */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'
import Actions from './actions'
import { RefreshableScrollView } from '../../../common/components/RefreshableList'
import AssignmentSection from '../../assignment-details/components/AssignmentSection'
import WebContainer from '../../../common/components/WebContainer'
import Avatar from '../../../common/components/Avatar'
import { formattedDate } from '../../../utils/dateUtils'

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
      let participants = discussion.participants || []
      let user = discussion.author
      content = (
        <RefreshableScrollView
          refreshing={this.props.refreshing}
          onRefresh={this.props.refresh}>

          <View style={style.container}>

            <Heading1 style={style.title}>{discussion.title}</Heading1>

            <View style={style.authorContainer}>
              {user && <Avatar height={32} key={user.id} avatarURL={user.avatar_image_url} userName={user.display_name}
                               style={style.avatar}/> }
              <View style={style.authorInfoContainer}>
                <Text style={style.authorName}>{user.display_name} </Text>
                <Text style={style.authorDate}>{formattedDate(discussion.posted_at)}</Text>
              </View>
            </View>

            { Boolean(discussion.message) &&
            <View style={style.section}>
              <WebContainer style={{ flex: 1 }} scrollEnabled={false} html={discussion.message}/>
            </View>
            }

          </View>

            <AssignmentSection isFirstRow={false} style={style.topContainer}>
              <Heading1>Replies</Heading1>
            </AssignmentSection>

          <DiscussionReplies style={style.replyContainer} replies={discussion.replies} participants={participants}/>

        </RefreshableScrollView>
      )
    }

    return (
      <Screen title={i18n('Discussion Details')}>
        {content}
      </Screen>
    )
  }
}

const style = StyleSheet.create({
  container: {
    padding: global.style.defaultPadding,
  },
  authorContainer: {
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'center',
    marginTop: global.style.defaultPadding,
  },
  authorInfoContainer: {
    flex: 1,
    marginLeft: global.style.defaultPadding,
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
    flex: 1,
    paddingTop: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
    paddingBottom: global.style.defaultPadding,
    paddingLeft: global.style.defaultPadding,
  },
})

export function mapStateToProps ({ entities }: AppState, { courseID, discussionID }: OwnProps): State {
  let discussion: ?Discussion
  let pending = 0
  let error = null

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
