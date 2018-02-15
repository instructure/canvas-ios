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

import React, { PureComponent } from 'react'
import {
  StyleSheet,
  View,
  TouchableHighlight,
  Image,
} from 'react-native'
import i18n from 'format-message'

import Row from '../../../common/components/rows/Row'
import AccessIcon from '../../../common/components/AccessIcon'
import { formattedDueDateWithStatus, formattedDueDate } from '../../../common/formatters'
import { extractDateFromString } from '../../../utils/dateUtils'
import Images from '../../../images/'
import { DotSeparated, Text } from '../../../common/text'

export type Props = {
  discussion: Discussion,
  onPress: (discussion: Discussion) => void,
  index: number,
  tintColor: ?string,
  onToggleDiscussionGrouping: Function,
}

export default class DiscussionsRow extends PureComponent<Props> {
  render () {
    const discussion = this.props.discussion
    const points = this._points(discussion)
    const discussionDetails = this._discussionDetails(discussion)
    const unreadDot = this._renderUnreadDot(discussion)
    return (
      <View accessible={false}>
        <View accessible={false}>
          <Row accessible={false}
            accessibilityLabel={`${discussion.title}`}
            renderImage={this._renderIcon}
            title={discussion.title || i18n('No Title')}
            titleProps={{ ellipsizeMode: 'tail', numberOfLines: 2 }}
            border='bottom'
            disclosureIndicator={false}
            testID={`discussion-row-${this.props.index}`}
            onPress={this._onPress}
            height='auto'
          >
            <View style={style.rowContent}>
              <View style={style.mainContentColumn} accessible={false}>
                <DotSeparated style={style.subtitle} separated={this._dueDate(discussion)}/>

                {points &&
                <View style={style.details}>
                  <Text style={style.points}>{points}</Text>
                </View>
                }

                {discussionDetails &&
                <View style={style.details}>
                  {discussionDetails}
                </View>
                }
              </View>
              { this._renderKabob() }
            </View>
          </Row>

        </View>
        {discussion.published ? <View style={style.publishedIndicatorLine}/> : <View />}
        { unreadDot }
      </View>
    )
  }

  _renderKabob = () => {
    const discussion = this.props.discussion
    return (
      <TouchableHighlight
        style={style.kabobButton}
        onPress={this._onToggleDiscussionGrouping}
        accessibilityTraits='button'
        accessible={true}
        accessibilityLabel={i18n('Change {discussionTitle} to different grouping', { discussionTitle: discussion.title })}
        underlayColor='#ffffff00'
        testID={`discussion.kabob-${this.props.discussion.id}`}
      >
        <Image style={style.kabob} source={Images.kabob}/>
      </TouchableHighlight>
    )
  }

  _onPress = () => {
    this.props.onPress(this.props.discussion)
  }

  _onToggleDiscussionGrouping = () => {
    this.props.onToggleDiscussionGrouping(this.props.discussion)
  }

  _dueDate = (discussion: Discussion) => {
    const { due_at, lock_at } = (discussion.assignment || {})
    const { last_reply_at } = discussion
    const dueAt = extractDateFromString(due_at)
    const lockAt = extractDateFromString(lock_at)
    const lastReply = extractDateFromString(last_reply_at)
    if (!dueAt && lastReply) {
      let lastReplyDateStr = formattedDueDate(lastReply)
      let lastPostAt = i18n('Last post {lastReplyDateStr}', { lastReplyDateStr })
      return [lastPostAt]
    }
    return formattedDueDateWithStatus(dueAt, lockAt)
  }

  _renderUnreadDot = (discussion: Discussion) => {
    if (discussion.unread_count > 0) {
      return (<View style={style.unreadDot}/>)
    } else {
      return (<View />)
    }
  }

  _renderIcon = () => {
    const { discussion } = this.props
    return (
      <View style={style.icon}>
        <AccessIcon
          entry={discussion}
          tintColor={this.props.tintColor}
          image={discussion.assignment ? Images.course.assignments : Images.course.discussions}
        />
      </View>
    )
  }

  _discussionDetails (discussion: Discussion) {
    const replies = i18n({
      default: `{
        count, plural,
        one {# Reply}
        other {# Replies}
      }`,
      message: 'Number of replies',
    }, { count: discussion.discussion_subentry_count })
    const unread = `${discussion.unread_count} ${i18n('Unread')}`

    return <DotSeparated style={style.discussionDetails} separated={[replies, unread].filter(v => v)}/>
  }

  _points = (discussion: Discussion) => {
    if (discussion.assignment) {
      const pointsPossible = Boolean(discussion.assignment.points_possible) && i18n({
        default: `{
        count, plural,
        one {# pt}
        other {# pts}
      }`,
        message: 'Number of points possible',
      }, { count: discussion.assignment.points_possible })
      return pointsPossible
    }
  }
}

const unreadDotSize = 5
const style = StyleSheet.create({
  rowContent: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
  },
  mainContentColumn: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
  },
  publishedIndicatorLine: {
    backgroundColor: '#00AC18',
    position: 'absolute',
    top: 4,
    bottom: 4,
    left: 0,
    width: 3,
  },
  details: {
    flexDirection: 'row',
    paddingTop: 2,
  },
  icon: {
    alignSelf: 'flex-start',
  },
  subtitle: {
    color: '#8B969E',
    fontSize: 14,
    marginTop: 2,
  },
  points: {
    fontSize: 14,
  },
  discussionDetails: {
    fontSize: 14,
  },
  unreadDot: {
    width: unreadDotSize,
    height: unreadDotSize,
    borderRadius: unreadDotSize / 2,
    backgroundColor: '#008EE4',
    position: 'absolute',
    top: 6,
    left: 8,
  },
  kabobButton: {
    flex: 0,
    flexDirection: 'column',
    justifyContent: 'center',
    alignSelf: 'center',
    width: 43,
    height: 43,
    marginTop: -15,
    marginRight: -global.style.defaultPadding / 2,
  },
  kabob: {
    alignSelf: 'center',
    width: 18,
    height: 18,
    tintColor: '#000',
    transform: [{ rotate: '180deg' }],
  },
})
