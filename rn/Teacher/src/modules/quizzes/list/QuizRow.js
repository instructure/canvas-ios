/* @flow */

import React, { Component } from 'react'
import {
  StyleSheet,
  View,
  Text,
} from 'react-native'
import i18n from 'format-message'

import Row from '../../../common/components/rows/Row'
import PublishedIcon from '../../../common/components/PublishedIcon'
import { formattedDueDateWithStatus } from '../../../common/formatters'
import { extractDateFromString } from '../../../utils/dateUtils'
import Images from '../../../images/'

export type Props = {
  quiz: Quiz,
  onPress: (quiz: Quiz) => void,
  index: number,
  tintColor: ?string,
}

export default class QuizRow extends Component<any, Props, any> {
  render () {
    const quiz = this.props.quiz
    return (
      <View>
        <View style={{ marginLeft: -12 }}>
          <Row
            renderImage={this._renderIcon}
            title={{ value: quiz.title, ellipsizeMode: 'tail', numberOfLines: 2 }}
            subtitle={this._dueDate(quiz)}
            border='bottom'
            disclosureIndicator={true}
            testID={`quiz-row-${this.props.index}`}
            onPress={this._onPress}
          >
            <View style={style.details}>
              <Text>{this._details()}</Text>
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
    return [
      pointsPossible,
      questionCount,
    ].filter(s => s).join(' • ')
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
})
