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

import React, { PureComponent } from 'react'
import {
  View,
} from 'react-native'

import AccessIcon from '../../common/components/AccessIcon'
import Row from '../../common/components/rows/Row'
import instIcon from '../../images/inst-icons'
import SubmissionStatusLabel from '../submissions/list/SubmissionStatusLabel'
import { submissionTypeIsOnline } from '@common/submissionTypes'
import { Text } from '@common/text'
import { formatStudentGrade } from '@common/formatters'
import { createStyleSheet } from '../../common/stylesheet'

type Props = {
  assignment: Assignment,
  tintColor?: string,
  onPress?: (Assignment) => void,
  selected?: boolean,
  user?: SessionUser,
}

export default class GradesListRow extends PureComponent<Props> {
  onPress = () => {
    const { assignment, onPress } = this.props
    onPress && onPress(assignment)
  }

  render () {
    const { assignment, selected } = this.props
    const { submission } = assignment
    const onlineSubmissionType = assignment.submission_types.every(submissionTypeIsOnline)
    const grade = formatStudentGrade(assignment)
    return (
      <Row
        renderImage={this._renderIcon}
        title={assignment.name}
        titleProps={{ ellipsizeMode: 'tail', numberOfLines: 2 }}
        border='bottom'
        disclosureIndicator
        testID={`grades-list.grades-list-row.cell-${assignment.id}`}
        onPress={this.onPress}
        selected={selected}
        height='auto'
        accessories={
          <Text style={styles.gradeText}>{grade}</Text>
        }
      >
        {assignment.grading_type !== 'not_graded' &&
          <SubmissionStatusLabel submission={submission} onlineSubmissionType={onlineSubmissionType} />
        }
      </Row>
    )
  }

  _renderIcon = () => {
    const assignment = this.props.assignment
    let image = instIcon('assignment')
    let testIDSuffix = `-icon-${assignment.published ? 'published' : 'not-published'}-${assignment.id}.icon-img`
    let testID = `grades-list-row-assignment${testIDSuffix}`
    if (assignment.submission_types.includes('online_quiz')) {
      image = instIcon('quiz')
      testID = `grades-list-row-quiz${testIDSuffix}`
    } else if (assignment.submission_types.includes('discussion_topic')) {
      image = instIcon('discussion')
      testID = `grades-list-row-discussion${testIDSuffix}`
    }
    return (
      <View style={styles.icon} testID={testID}>
        <AccessIcon entry={assignment} tintColor={this.props.tintColor} style={styles.icon} image={image} />
      </View>
    )
  }
}

const styles = createStyleSheet(colors => ({
  ungradedText: {
    flex: 0,
    alignSelf: 'flex-start',
    fontSize: 11,
    fontWeight: '600',
    color: colors.textInfo,
    borderRadius: 9,
    borderColor: colors.textInfo,
    borderWidth: 1,
    backgroundColor: colors.backgroundLightest,
    paddingTop: 3,
    paddingBottom: 1,
    paddingLeft: 6,
    paddingRight: 6,
    marginTop: 4,
    overflow: 'hidden',
  },
  gradeText: {
    fontSize: 14,
    fontWeight: '600',
    alignSelf: 'center',
  },
  icon: {
    alignSelf: 'flex-start',
  },
}))
