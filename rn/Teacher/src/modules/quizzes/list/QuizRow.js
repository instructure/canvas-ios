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
  quiz: Quiz,
  onPress: (quiz: Quiz) => void,
  index: number,
  tintColor: ?string,
  selected: boolean,
}

export default class QuizRow extends Component<any, Props, any> {
  render () {
    const { quiz, selected } = this.props
    return (
      <View>
        <View style={{ marginLeft: -12 }}>
          <Row
            renderImage={this._renderIcon}
            title={quiz.title}
            titleProps={{ ellipsizeMode: 'tail', numberOfLines: 2 }}
            border='bottom'
            disclosureIndicator={true}
            testID={`quiz-row-${this.props.index}`}
            onPress={this._onPress}
            height='auto'
            selected={selected}
          >
            <DotSeparated style={style.subtitle} separated={this._dueDate(quiz)} />
            <View style={style.details}>
              {this._details()}
            </View>
          </Row>
        </View>
        {quiz.published ? <View style={style.publishedIndicatorLine} /> : <View />}
      </View>
    )
  }

  _onPress = () => {
    this.props.onPress(this.props.quiz)
  }

  _dueDate = () => {
    const { due_at, lock_at } = this.props.quiz
    const dueAt = extractDateFromString(due_at)
    const lockAt = extractDateFromString(lock_at)
    return formattedDueDateWithStatus(dueAt, lockAt)
  }

  _renderIcon = () => {
    return (
      <View style={style.icon}>
        <PublishedIcon published={this.props.quiz.published} tintColor={this.props.tintColor} image={Images.course.quizzes} />
      </View>
    )
  }

  _details = () => {
    const quiz = this.props.quiz
    const pointsPossible = Boolean(quiz.points_possible) && i18n({
      default: `{
        count, plural,
        one {# pt}
        other {# pts}
      }`,
      message: 'Number of points possible',
    }, { count: quiz.points_possible })
    const questionCount = i18n(`{
      count, plural,
      one {# Question}
      other {# Questions}
    }`, { count: quiz.question_count })
    return <DotSeparated separated={[pointsPossible, questionCount].filter(v => v)} />
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
