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

/**
* @flow
*/

import i18n from 'format-message'
import React, { Component } from 'react'
import {
  View,
} from 'react-native'

import AccessIcon from '../../common/components/AccessIcon'
import { Text } from '../../common/text'
import Row from '../../common/components/rows/Row'
import instIcon from '../../images/inst-icons'
import OldSubmissionStatusLabel from '../submissions/list/OldSubmissionStatusLabel'
import LinearGradient from 'react-native-linear-gradient'
import Token from '../../common/components/Token'
import { colors, createStyleSheet } from '../../common/stylesheet'
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
    return <OldSubmissionStatusLabel style={{ marginBottom: 8 }} status={status} />
  }

  grade = () => {
    const submission = this.props.submission
    const assignment = submission.assignment
    const grade = formatGradeText({
      grade: submission.grade,
      score: submission.score,
      gradingType: assignment.grading_type,
      pointsPossible: assignment.points_possible,
    })
    let flex = 1
    // if points_possible is zero we would divide by zero and get NaN
    if (assignment.points_possible > 0) {
      flex = Math.min(1, (submission.score ?? 0) / assignment.points_possible)
    }

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
      <Row
        renderImage={this._renderIcon}
        title={assignment.name}
        titleProps={{ ellipsizeMode: 'tail', numberOfLines: 2 }}
        testID={`user-submission-row.cell-${assignment.id}`}
        onPress={this.onPress}
        height='auto'
      >
        {this.submissionStatus()}
        {submission.grading_status === 'graded' && this.grade()}
        {needsGrading &&
          <View style={{ flexDirection: 'row' }}>
            <Token color={colors.textWarning}>{i18n('Needs Grading')}</Token>
          </View>
        }
      </Row>
    )
  }

  _renderIcon = () => {
    const assignment = this.props.submission.assignment
    const testIDSuffix = `-icon-${assignment.published ? 'published' : 'not-published'}-${assignment.id}.icon-img`
    const submissionTypes = assignment.submission_types || []
    let image = instIcon('assignment')
    let testID = `user-submission-row${testIDSuffix}`
    if (submissionTypes.includes('online_quiz')) {
      image = instIcon('quiz')
      testID = `user-submission-row${testIDSuffix}`
    } else if (submissionTypes.includes('discussion_topic')) {
      image = instIcon('discussion')
      testID = `user-submission-row${testIDSuffix}`
    }
    return (
      <View style={styles.icon} testID={testID}>
        <AccessIcon entry={assignment} tintColor={this.props.tintColor} style={styles.icon} image={image} />
      </View>
    )
  }
}

const styles = createStyleSheet((colors, vars) => ({
  ungradedText: {
    flex: 0,
    alignSelf: 'flex-start',
    fontSize: 11,
    fontWeight: '600',
    color: colors.textInfo,
    borderRadius: 9,
    borderColor: colors.borderInfo,
    borderWidth: 1,
    backgroundColor: colors.backgroundLightest,
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
    backgroundColor: colors.backgroundLight,
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
    color: colors.textDark,
    fontWeight: '500',
  },
  needsGradingText: {
    flex: 0,
  },
}))
