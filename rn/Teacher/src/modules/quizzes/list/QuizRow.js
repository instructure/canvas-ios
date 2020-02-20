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

import React, { Component } from 'react'
import {
  View,
} from 'react-native'
import i18n from 'format-message'

import Row from '../../../common/components/rows/Row'
import AccessIcon from '../../../common/components/AccessIcon'
import { formattedDueDateWithStatus } from '../../../common/formatters'
import { extractDateFromString } from '../../../utils/dateUtils'
import instIcon from '../../../images/inst-icons'
import { DotSeparated } from '../../../common/text'
import { createStyleSheet } from '../../../common/stylesheet'

export type Props = {
  quiz: Quiz,
  onPress: (quiz: Quiz) => void,
  index: number,
  tintColor: ?string,
  selected: boolean,
}

export default class QuizRow extends Component<Props, any> {
  render () {
    const { quiz, selected } = this.props
    return (
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
        <DotSeparated style={style.subtitle} separated={this._dueDate()} />
        <View style={style.details}>
          {this._details()}
        </View>
      </Row>
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
        <AccessIcon entry={this.props.quiz} tintColor={this.props.tintColor} image={instIcon('quiz')} />
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
      description: 'Number of points possible',
    }, { count: quiz.points_possible })
    const questionCount = i18n(`{
      count, plural,
      one {# Question}
      other {# Questions}
    }`, { count: quiz.question_count })
    return <DotSeparated style={style.detailContent} separated={[pointsPossible, questionCount].filter(v => v)} />
  }
}

const style = createStyleSheet(colors => ({
  details: {
    flexDirection: 'row',
  },
  icon: {
    alignSelf: 'flex-start',
  },
  subtitle: {
    color: colors.textDark,
    fontSize: 14,
    marginTop: 2,
  },
  detailContent: {
    fontSize: 14,
  },
}))
