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

// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
} from 'react-native'
import Row from '../../../common/components/rows/Row'
import { Text } from '../../../common/text'
import PublishedIcon from '../../../common/components/PublishedIcon'
import colors from '../../../common/colors'
import i18n from 'format-message'
import images from '../../../images/'

type StateProps = {
  courseName: ?string,
  courseColor: ?string,
}

type OwnProps = {
  item: ToDoItem,
  index: number,
  onPress: (ToDoItem) => void,
}

export type Props = StateProps & OwnProps

export class ToDoListItem extends Component<Props, any> {
  render () {
    if (this.props.item.assignment) {
      return this._renderAssignment(this.props.item.assignment, this.props.item.needs_grading_count || 0)
    }

    if (this.props.item.quiz) {
      return this._renderQuiz(this.props.item.quiz, this.props.item.needs_grading_count || 0)
    }
  }

  _renderAssignment (assignment: Assignment, needsGradingCount: number) {
    let image = images.course.assignments
    if (assignment.submission_types.includes('discussion_topic')) {
      image = images.course.discussions
    }
    return this._renderNeedsGrading(
      assignment.name,
      assignment.due_at,
      needsGradingCount,
      assignment.published,
      image
    )
  }

  _renderQuiz (quiz: Quiz, needsGradingCount: number) {
    return this._renderNeedsGrading(
      quiz.title,
      quiz.due_at,
      needsGradingCount,
      quiz.published,
      images.course.quizzes
    )
  }

  _renderNeedsGrading (title: string, dueAt: ?string, count: number, published: boolean, image: any) {
    const renderIcon = () => {
      return (
        <View style={styles.icon}>
          <PublishedIcon
            published={published}
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

    return (
      <View>
        <View style={{ marginLeft: -10 }}>
          <Row
            title={title}
            renderImage={renderIcon}
            testID={`to-do.list.item-${this.props.index}.row`}
            onPress={this.props.onPress}
            disclosureIndicator
            accessible
          >
            <View style={{ flex: 1, flexDirection: 'column' }}>
              <Text
                style={[styles.courseName, { color: this.props.courseColor || 'black' }]}
              >
                {this.props.courseName}
              </Text>
              <Text style={styles.dueDate}>{dueLabel}</Text>
              <Text
                style={[
                  styles.needsGrading,
                  {
                    color: colors.primaryBrandColor,
                    borderColor: colors.primaryBrandColor,
                  },
                ]}
              >
                {text}
              </Text>
            </View>
          </Row>
        </View>
        { published &&
          <View style={styles.publishedIndicator} />
        }
      </View>
    )
  }
}

const styles = StyleSheet.create({
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
    color: '#8B969E',
  },
  needsGrading: {
    flex: 0,
    alignSelf: 'flex-start',
    fontSize: 11,
    fontWeight: '600',
    borderRadius: 9,
    borderWidth: 1,
    backgroundColor: 'white',
    paddingTop: 3,
    paddingBottom: 1,
    paddingLeft: 6,
    paddingRight: 6,
    marginTop: 4,
    overflow: 'hidden',
  },
  publishedIndicator: {
    backgroundColor: '#00AC18',
    position: 'absolute',
    top: 4,
    bottom: 4,
    left: 0,
    width: 3,
  },
})

export function mapStateToProps ({ entities }: AppState, { item }: OwnProps): StateProps {
  let courseName = null
  let courseColor = null

  if (item.course_id && entities.courses && entities.courses[item.course_id]) {
    const { color, course } = entities.courses[item.course_id]
    courseColor = color
    courseName = course && course.name
  }

  return {
    courseName,
    courseColor,
  }
}

const Connected = connect(mapStateToProps)(ToDoListItem)
export default (Connected: *)
