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

import AccessIcon from '../../common/components/AccessIcon'
import AccessLine from '../../common/components/AccessLine'
import { Text } from '../../common/text'
import Row from '../../common/components/rows/Row'
import Images from '../../images'
import SubmissionStatusLabel from '../submissions/list/SubmissionStatusLabel'
import LinearGradient from 'react-native-linear-gradient'
import Token from '../../common/components/Token'
import colors from '../../common/colors'
import { formatGradeText } from '../../common/formatters'

type Props = {
  submission: SubmissionV2,
  tintColor: string,
  onPress: (Assignment) => void,
}

export default class UserSubmissionRow extends Component<Props, any> {
  onPress = () => {
    const assignment = this.props.submission.assignment
    this.props.onPress(assignment)
  }

  submissionStatus = () => {
    let status = 'none'
    if (this.props.submission && this.props.submission.excused) {
      status = 'excused'
    } else {
      status = this.props.submission.submission_status
    }
    return <SubmissionStatusLabel style={{ marginBottom: 8 }} status={status} />
  }

  grade = () => {
    const submission = this.props.submission
    const assignment = submission.assignment
    const grade = formatGradeText(submission.grade, assignment.grading_type, assignment.points_possible)
    const flex = Math.min(1, (submission.score || 0) / assignment.points_possible)
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
    const { submission } = this.props
    const assignment = submission.assignment
    const needsGrading = submission.grading_status === 'needs_grading'

    return (
      <View>
        <View>
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
            {submission.grading_status === 'graded' && this.grade()}
            {needsGrading &&
              <View style={{ flexDirection: 'row' }}>
                <Token color='#FC5E13'>{i18n('Needs Grading')}</Token>
              </View>
            }
          </Row>
        </View>
        <AccessLine visible={assignment.published} />
      </View>
    )
  }

  _renderIcon = () => {
    const assignment = this.props.submission.assignment
    const testIDSuffix = `-icon-${assignment.published ? 'published' : 'not-published'}-${assignment.id}.icon-img`
    const submissionTypes = assignment.submission_types || []
    let image = Images.course.assignments
    let testID = `user-submission-row${testIDSuffix}`
    if (submissionTypes.includes('online_quiz')) {
      image = Images.course.quizzes
      testID = `user-submission-row${testIDSuffix}`
    } else if (submissionTypes.includes('discussion_topic')) {
      image = Images.course.discussions
      testID = `user-submission-row${testIDSuffix}`
    }
    return (
      <View style={styles.icon} testID={testID}>
        <AccessIcon entry={assignment} tintColor={this.props.tintColor} style={styles.icon} image={image} />
      </View>
    )
  }
}

const styles = StyleSheet.create({
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
