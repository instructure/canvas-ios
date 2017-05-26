/* @flow */

import React, { Component } from 'react'
import {
  StyleSheet,
  View,
} from 'react-native'
import i18n from 'format-message'

import Row from '../../../common/components/rows/Row'
import PublishedIcon from '../../../common/components/PublishedIcon'
import { formattedDueDateWithStatus } from '../../../common/formatters'
import { extractDateFromString } from '../../../utils/dateUtils'
import Images from '../../../images/'
import { DotSeparated } from '../../../common/text'

export type Props = {
  discussion: Discussion,
  onPress: (discussion: Discussion) => void,
  index: number,
  tintColor: ?string,
}

export default class DiscussionsRow extends Component<any, Props, any> {
  render () {
    const discussion = this.props.discussion
    return (
      <View>
        <View style={{ marginLeft: -12 }}>
          <Row
            renderImage={this._renderIcon}
            title={discussion.title}
            titleProps={{ ellipsizeMode: 'tail', numberOfLines: 2 }}
            border='bottom'
            disclosureIndicator={true}
            testID={`discussion-row-${this.props.index}`}
            onPress={this._onPress}
            height='auto'
          >
            <DotSeparated style={style.subtitle} separated={this._dueDate(discussion)} />
            <View style={style.details}>
              {this._details()}
            </View>
          </Row>
        </View>
        {discussion.published ? <View style={style.publishedIndicatorLine} /> : <View />}
      </View>
    )
  }

  _onPress = () => {
    this.props.onPress(this.props.discussion)
  }

  _dueDate = (discussion: Discussion) => {
    const { due_at, lock_at } = (discussion.assignment || {})
    const dueAt = extractDateFromString(due_at)
    const lockAt = extractDateFromString(lock_at)
    return formattedDueDateWithStatus(dueAt, lockAt)
  }

  _renderIcon = () => {
    return (
      <View style={style.icon}>
        <PublishedIcon published={this.props.discussion.published} tintColor={this.props.tintColor} image={Images.course.quizzes} />
      </View>
    )
  }

  _details = () => {
    const discussion = this.props.discussion
    if (discussion.assignment) {
      const pointsPossible = Boolean(discussion.assignment.points_possible) && i18n({
        default: `{
        count, plural,
        one {# pt}
        other {# pts}
      }`,
        message: 'Number of points possible',
      }, { count: discussion.assignment.points_possible })
      return <DotSeparated separated={[pointsPossible].filter(v => v)} />
    }
  }
}

const style = StyleSheet.create({
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
  },
  icon: {
    alignSelf: 'flex-start',
  },
  subtitle: {
    color: '#8B969E',
    fontSize: 14,
    marginTop: 2,
  },
})
