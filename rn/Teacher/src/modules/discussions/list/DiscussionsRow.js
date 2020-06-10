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

import React, { PureComponent } from 'react'
import {
  View,
  TouchableHighlight,
  Image,
} from 'react-native'
import i18n from 'format-message'
import { createStyleSheet } from '../../../common/stylesheet'

import Row from '../../../common/components/rows/Row'
import AccessIcon from '../../../common/components/AccessIcon'
import { formattedDueDateWithStatus, formattedDueDate } from '../../../common/formatters'
import { extractDateFromString } from '../../../utils/dateUtils'
import instIcon from '../../../images/inst-icons'
import { DotSeparated, Text } from '../../../common/text'
import { isTeacher } from '../../app'

export type Props = {
  discussion: Discussion,
  onPress: (discussion: Discussion) => void,
  index: number,
  tintColor: ?string,
  onToggleDiscussionGrouping: Function,
  selected: boolean,
}

export default class DiscussionsRow extends PureComponent<Props> {
  render () {
    const { selected, discussion } = this.props
    const points = this.points(discussion)
    const discussionDetails = this.discussionDetails(discussion)
    const unreadDot = this.renderUnreadDot(discussion)
    return (
      <View>
        <View accessible={false}>
          <Row accessible={true}
            renderImage={this.renderIcon}
            title={discussion.title}
            titleProps={{ ellipsizeMode: 'tail', numberOfLines: 2 }}
            border='bottom'
            disclosureIndicator={false}
            testID={`DiscussionListCell.${discussion.id}`}
            onPress={this.onPress}
            height='auto'
            selected={selected}
          >
            <View style={style.rowContent}>
              <View style={style.mainContentColumn} accessible={false}>
                <DotSeparated style={style.subtitle} separated={this.dueDate(discussion)}/>

                {points &&
                  <View testID='discussion.row.points' style={style.details}>
                    <Text style={style.points}>{points}</Text>
                  </View>
                }

                {discussionDetails &&
                  <View testID='discussion.row.details' style={style.details}>
                    {discussionDetails}
                  </View>
                }
              </View>
              { isTeacher() && this.renderKabob() }
            </View>
          </Row>

        </View>
        { unreadDot }
      </View>
    )
  }

  renderKabob = () => {
    const discussion = this.props.discussion
    return (
      <TouchableHighlight
        style={style.kabobButton}
        onPress={this.onToggleDiscussionGrouping}
        accessibilityTraits='button'
        accessible={true}
        accessibilityLabel={i18n('Change {discussionTitle} to different grouping', { discussionTitle: discussion.title })}
        underlayColor='#ffffff00'
        testID={`discussion.kabob-${this.props.discussion.id}`}
      >
        <Image style={style.kabob} source={instIcon('more')}/>
      </TouchableHighlight>
    )
  }

  onPress = () => {
    this.props.onPress(this.props.discussion)
  }

  onToggleDiscussionGrouping = () => {
    this.props.onToggleDiscussionGrouping(this.props.discussion)
  }

  dueDate = (discussion: Discussion) => {
    const { due_at, lock_at, has_overrides: multiple } = (discussion.assignment || {})
    const { last_reply_at } = discussion
    const dueAt = extractDateFromString(due_at)
    const lockAt = extractDateFromString(lock_at)
    const lastReply = extractDateFromString(last_reply_at)
    if (!dueAt && lastReply) {
      let lastReplyDateStr = formattedDueDate(lastReply)
      let lastPostAt = i18n('Last post {lastReplyDateStr}', { lastReplyDateStr })
      return [lastPostAt]
    }
    if (isTeacher() && dueAt && multiple) {
      return [i18n('Multiple Due Dates')]
    }
    return formattedDueDateWithStatus(dueAt, lockAt)
  }

  renderUnreadDot = (discussion: Discussion) => {
    if (discussion.unread_count > 0) {
      return (<View testID='discussions.row.unread-dot' style={style.unreadDot}/>)
    } else {
      return (<View testID='discussions.row.unread-dot' />)
    }
  }

  renderIcon = () => {
    const { discussion } = this.props
    return (
      <View style={style.icon}>
        <AccessIcon
          entry={discussion}
          tintColor={this.props.tintColor}
          image={instIcon(discussion.assignment ? 'assignment' : 'discussion')}
        />
      </View>
    )
  }

  discussionDetails (discussion: Discussion) {
    const replies = i18n({
      default: `{
        count, plural,
        one {# Reply}
        other {# Replies}
      }`,
      description: 'Number of replies',
    }, { count: discussion.discussion_subentry_count })
    const unread = i18n({
      default: `{
        unread, plural,
          one {# Unread}
        other {# Unread}
      }`,
      description: 'Number of unread discussion posts',
    }, { unread: discussion.unread_count })

    return <DotSeparated style={style.discussionDetails} separated={[replies, unread].filter(v => v)}/>
  }

  points = (discussion: Discussion) => {
    if (discussion.assignment) {
      const pointsPossible = Boolean(discussion.assignment.points_possible) && i18n({
        default: `{
        count, plural,
        one {# pt}
        other {# pts}
      }`,
        description: 'Number of points possible',
      }, { count: discussion.assignment.points_possible })
      return pointsPossible
    }
  }
}

const unreadDotSize = 5
const style = createStyleSheet((colors, vars) => ({
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
  details: {
    flexDirection: 'row',
    paddingTop: 2,
  },
  icon: {
    alignSelf: 'flex-start',
  },
  subtitle: {
    color: colors.textDark,
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
    backgroundColor: colors.textInfo,
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
    marginRight: -vars.padding / 2,
  },
  kabob: {
    alignSelf: 'center',
    width: 18,
    height: 18,
    tintColor: colors.textDark,
    transform: [{ rotate: '180deg' }],
  },
}))
