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

import React, { PureComponent } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'

import i18n from 'format-message'
import { formattedDueDateWithStatus } from '../../../common/formatters'
import AccessIcon from '../../../common/components/AccessIcon'
import AccessLine from '../../../common/components/AccessLine'
import AssignmentDates from '../../../common/AssignmentDates'
import { Text } from '../../../common/text'
import Row from '../../../common/components/rows/Row'
import Images from '../../../images'

type Props = {
  assignment: Assignment,
  tintColor: string,
  onPress: (Assignment) => void,
  selected: boolean,
}

export default class AssignmentListRow extends PureComponent<Props> {
  onPress = () => {
    const assignment = this.props.assignment
    this.props.onPress(assignment)
  }

  dueDate (assignment: Assignment): string {
    const dates = new AssignmentDates(assignment)

    if (dates.availabilityClosed()) {
      return i18n('Availability: Closed')
    }

    if (dates.hasMultipleDueDates()) {
      return i18n('Multiple Due Dates')
    }

    return formattedDueDateWithStatus(dates.bestDueAt(), dates.bestAvailableTo()).join('  •  ')
  }

  ungradedBubble (assignment: Assignment) {
    if (!assignment.needs_grading_count || assignment.grading_type === 'not_graded') {
      return <View />
    }

    const text = i18n(`{
      count, plural,
        one {# Needs Grading}
      other {# Need Grading}
    }`, { count: assignment.needs_grading_count }).toUpperCase()
    return (
      <Text style={styles.ungradedText}>{text}</Text>
    )
  }

  render () {
    const { assignment, selected } = this.props
    return (
      <View>
        <View>
          <Row
            renderImage={this._renderIcon}
            title={assignment.name}
            titleProps={{ ellipsizeMode: 'tail', numberOfLines: 2 }}
            subtitle={this.dueDate(assignment)}
            border='bottom'
            disclosureIndicator={true}
            testID={`assignment-list.assignment-list-row.cell-${assignment.id}`}
            onPress={this.onPress}
            selected={selected}
            height='auto'
          >
            {this.ungradedBubble(assignment)}
          </Row>
        </View>
        <AccessLine visible={assignment.published} />
      </View>
    )
  }

  _renderIcon = () => {
    const assignment = this.props.assignment
    let image = Images.course.assignments
    let testIDSuffix = `-icon-${assignment.published ? 'published' : 'not-published'}-${assignment.id}.icon-img`
    let testID = `assignment-list-row-assignment${testIDSuffix}`
    if (assignment.submission_types.includes('online_quiz')) {
      image = Images.course.quizzes
      testID = `assignment-list-row-quiz${testIDSuffix}`
    } else if (assignment.submission_types.includes('discussion_topic')) {
      image = Images.course.discussions
      testID = `assignment-list-row-discussion${testIDSuffix}`
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
})
