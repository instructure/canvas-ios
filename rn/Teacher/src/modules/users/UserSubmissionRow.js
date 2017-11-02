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

/**
* @flow
*/

import i18n from 'format-message'
import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'

import Icon from '../../common/components/PublishedIcon'
import { Text } from '../../common/text'
import Row from '../../common/components/rows/Row'
import Images from '../../images'
import { gradeProp, statusProp, dueDate } from '../submissions/list/get-submissions-props'
import SubmissionStatus from '../submissions/list/SubmissionStatus'
import LinearGradient from 'react-native-linear-gradient'
import Token from '../../common/components/Token'
import colors from '../../common/colors'
import { formatGradeText } from '../../common/formatters'

type Props = {
  assignment: Assignment,
  submission: Submission,
  user: User,
  tintColor: string,
  onPress: (Assignment) => void,
}

export default class UserSubmissionRow extends Component<any, Props, any> {
  onPress = () => {
    const assignment = this.props.assignment
    this.props.onPress(assignment)
  }

  submissionStatus = () => {
    let status = ''
    if (this.props.submission && this.props.submission.excused) {
      status = 'excused'
    } else {
      let due = dueDate(this.props.assignment, this.props.user)
      status = statusProp(this.props.submission, due)
    }
    return <SubmissionStatus style={{ marginBottom: 8 }} status={status} />
  }

  grade = () => {
    const grade = formatGradeText(this.props.submission.grade, this.props.assignment.grading_type, this.props.assignment.points_possible)
    const flex = Math.min(1, (this.props.submission.score || 0) / this.props.assignment.points_possible)
    return (
      <View style={styles.gradeWrapper}>
        <View style={styles.progressWrapper}>
          <View
            style={styles.progressBackground}
          />
          <View style={styles.gradientWrapper}>
            <LinearGradient
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={{
                flex,
                height: 18,
              }}
              colors={['#008EE2', '#00C1F3']}
            />
          </View>
        </View>
        <Text style={styles.gradeText}>{grade}</Text>
      </View>
    )
  }

  render () {
    const { assignment, submission } = this.props
    const hasGrade = submission &&
                     submission.grade &&
                     submission.grade_matches_current_submission
    const needsGrading = gradeProp(submission) === 'ungraded'

    return (
      <View>
        <View style={styles.row}>
          <Row
            renderImage={this._renderIcon}
            title={assignment.name}
            titleProps={{ ellipsizeMode: 'tail', numberOfLines: 2 }}
            border='bottom'
            testID={`user-submission-row.cell-${assignment.id}`}
            onPress={this.onPress}
            height='auto'
          >
            {this.submissionStatus()}
            {hasGrade && !submission.excused && this.grade()}
            {needsGrading &&
              <View style={{ flexDirection: 'row' }}>
                <Token color='#FC5E13'>{i18n('Needs Grading')}</Token>
              </View>
            }
          </Row>
        </View>
        {this.props.assignment.published ? <View style={styles.publishedIndicatorLine} /> : <View />}
      </View>
    )
  }

  _renderIcon = () => {
    const assignment = this.props.assignment
    let image = Images.course.assignments
    let testIDSuffix = `-icon-${assignment.published ? 'published' : 'not-published'}-${assignment.id}.icon-img`
    let testID = `user-submission-row${testIDSuffix}`
    if (assignment.submission_types.includes('online_quiz')) {
      image = Images.course.quizzes
      testID = `user-submission-row${testIDSuffix}`
    } else if (assignment.submission_types.includes('discussion_topic')) {
      image = Images.course.discussions
      testID = `user-submission-row${testIDSuffix}`
    }
    return (
      <View style={styles.icon} testID={testID}>
        <Icon published={assignment.published} tintColor={this.props.tintColor} style={styles.icon} image={image} />
      </View>
    )
  }
}

const styles = StyleSheet.create({
  row: {
    marginLeft: -10,
  },
  ungradedText: {
    flex: 0,
    alignSelf: 'flex-start',
    fontSize: 11,
    fontWeight: '600',
    color: '#008EE2',
    borderRadius: 9,
    borderColor: '#008EE2',
    borderWidth: 1,
    backgroundColor: 'white',
    paddingTop: 3,
    paddingBottom: 1,
    paddingLeft: 6,
    paddingRight: 6,
    marginTop: 4,
    overflow: 'hidden',
  },
  publishedIndicatorLine: {
    backgroundColor: '#00AC18',
    position: 'absolute',
    top: 4,
    bottom: 4,
    left: 0,
    width: 3,
  },
  icon: {
    alignSelf: 'flex-start',
  },
  gradeWrapper: {
    flexDirection: 'row',
  },
  progressWrapper: {
    flex: 1,
    marginRight: 8,
  },
  progressBackground: {
    backgroundColor: '#f5f5f5',
    borderColor: 'transparent',
    height: 18,
    flex: 1,
  },
  gradientWrapper: {
    position: 'absolute',
    left: 0,
    right: 0,
    height: 18,
    flexDirection: 'row',
  },
  gradeText: {
    minWidth: 67,
    flex: 0,
    fontSize: 14,
    color: colors.lightText,
    fontWeight: '500',
  },
  needsGradingText: {
    flex: 0,
  },
})
