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

// @flow

import i18n from 'format-message'
import React, { Component } from 'react'
import {
  View,
} from 'react-native'
import Row from '../../../common/components/rows/Row'
import { Text } from '../../../common/text'
import AccessIcon from '../../../common/components/AccessIcon'
import { colors, createStyleSheet } from '../../../common/stylesheet'
import instIcon from '../../../images/inst-icons'
import {
  fetchPropsFor,
  type FetchProps,
  ToDoModel,
} from '../../../canvas-api/model-api'

type HocProps = {
  item: ToDoModel,
  onPress: (ToDoModel) => void,
}
type Props = HocProps & {
  courseName: ?string,
  courseColor: string,
} & FetchProps

export class ToDoListItem extends Component<Props> {
  handlePress = () => {
    this.props.onPress(this.props.item)
  }

  render () {
    if (this.props.item.assignment) {
      return this.renderAssignment(this.props.item.assignment, this.props.item.needsGradingCount || 0)
    }

    if (this.props.item.quiz) {
      return this.renderQuiz(this.props.item.quiz, this.props.item.needsGradingCount || 0)
    }
  }

  renderAssignment (assignment: Assignment, needsGradingCount: number) {
    let image = instIcon('assignment')
    if (assignment.submission_types.includes('discussion_topic')) {
      image = instIcon('discussion')
    }
    return this.renderNeedsGrading(
      assignment.name,
      assignment.due_at,
      needsGradingCount,
      assignment,
      image
    )
  }

  renderQuiz (quiz: Quiz, needsGradingCount: number) {
    return this.renderNeedsGrading(
      quiz.title,
      quiz.due_at,
      needsGradingCount,
      quiz,
      instIcon('quiz')
    )
  }

  renderNeedsGrading (title: string, dueAt: ?string, count: number, entry: Quiz | Assignment, image: any) {
    const renderIcon = () => {
      return (
        <View style={styles.icon}>
          <AccessIcon
            entry={entry}
            tintColor={this.props.courseColor}
            image={image}
          />
        </View>
      )
    }

    let dueLabel = i18n('No Due Date')
    if (dueAt) {
      dueLabel = i18n("Due { date, date, 'MMM d, YYYY'} at { date, time, short }", { date: new Date(dueAt) })
    }

    const text = i18n(`{
      count, plural,
        one {# Needs Grading}
      other {# Need Grading}
    }`, { count }).toUpperCase()

    const a11yLabel = `${this.props.courseName}, ${dueLabel}, ${text}`

    return (
      <Row
        title={title}
        renderImage={renderIcon}
        testID={`to-do.list.${ToDoModel.keyExtractor(this.props.item)}.row`}
        onPress={this.handlePress}
        disclosureIndicator
        accessible
      >
        <View style={{ flex: 1, flexDirection: 'column' }} accessibilityLabel={a11yLabel}>
          <Text
            style={[styles.courseName, { color: this.props.courseColor || 'black' }]}
          >
            {this.props.courseName}
          </Text>
          <Text style={styles.dueDate}>{dueLabel}</Text>
          <Text
            style={[ styles.needsGrading, {
              color: colors.primary,
              borderColor: colors.primary,
            } ]}
          >
            {text}
          </Text>
        </View>
      </Row>
    )
  }
}

const styles = createStyleSheet(colors => ({
  icon: {
    alignSelf: 'flex-start',
  },
  courseName: {
    fontWeight: '600',
    fontSize: 14,
  },
  dueDate: {
    marginTop: 3,
    fontSize: 13,
    color: colors.textDark,
  },
  needsGrading: {
    flex: 0,
    alignSelf: 'flex-start',
    fontSize: 11,
    fontWeight: '600',
    borderRadius: 9,
    borderWidth: 1,
    backgroundColor: colors.backgroundLightest,
    paddingTop: 3,
    paddingBottom: 1,
    paddingLeft: 6,
    paddingRight: 6,
    marginTop: 4,
    overflow: 'hidden',
  },
  publishedIndicator: {
    backgroundColor: colors.backgroundSuccess,
    position: 'absolute',
    top: 4,
    bottom: 4,
    left: 0,
    width: 3,
  },
}))

export default fetchPropsFor(ToDoListItem, ({ item }: HocProps, api) => {
  const course = api.getCourse(item.courseID || '')
  return {
    courseName: course && course.name || '',
    courseColor: api.getCourseColor(item.courseID || ''),
  }
})
