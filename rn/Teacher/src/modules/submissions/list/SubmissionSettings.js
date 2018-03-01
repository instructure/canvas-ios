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

import React, { PureComponent } from 'react'
import {
  ScrollView,
  StyleSheet,
} from 'react-native'
import Screen from '../../../routing/Screen'
import i18n from 'format-message'
import RowWithSwitch from '../../../common/components/rows/RowWithSwitch'
import RowSeparator from '../../../common/components/rows/RowSeparator'
import { connect } from 'react-redux'
import AssignmentActions from '../../assignments/actions'
import branding from '../../../common/branding'
import { SubTitle } from '../../../common/text'

type SubmissionSettingsOwnProps = {
  courseID: string,
  assignmentID: string,
  navigator: Navigator,
}
type SubmissionSettingsDataProps = {
  anonymous: boolean,
  muted: boolean,
  assignment: Assignment,
  disableAnonymous: boolean,
}
type SubmissionSettingsActions = {
  anonymousGrading: (string, string, boolean) => void,
  updateAssignment: (string, Assignment, Assignment) => void,
}

type SubmissionSettingsProps =
  SubmissionSettingsOwnProps &
  SubmissionSettingsDataProps &
  SubmissionSettingsActions

export class SubmissionSettings extends PureComponent<SubmissionSettingsProps> {
  props: SubmissionSettingsProps

  toggleAnonymousGrading = (value: boolean) => {
    this.props.anonymousGrading(
      this.props.courseID,
      this.props.assignmentID,
      value
    )
  }

  toggleMutedGrading = (value: boolean) => {
    this.props.updateAssignment(
      this.props.courseID,
      {
        ...this.props.assignment,
        muted: value,
      },
      this.props.assignment
    )
  }

  render () {
    return (
      <Screen
        title={i18n('Submission Settings')}
        navBarButtonColor={branding.primaryButtonColor}
      >
        <ScrollView style={style.container}>
          <RowSeparator />
          <RowWithSwitch
            title={i18n('Mute Grades')}
            value={this.props.muted}
            onValueChange={this.toggleMutedGrading}
            identifier='submission-settings.muted'
          />
          <RowSeparator />
          <RowWithSwitch
            title={i18n('Anonymous Grading')}
            value={this.props.anonymous}
            onValueChange={this.toggleAnonymousGrading}
            identifier='submission-settings.anonymous'
            disabled={this.props.disableAnonymous}
          />
          <RowSeparator />
          <SubTitle style={{ paddingHorizontal: 12, paddingVertical: 4 }}>
            {i18n('This will anonymize each student and shuffle the submission list.')}
          </SubTitle>
        </ScrollView>
      </Screen>
    )
  }
}

export function mapStateToProps (state: AppState, ownProps: SubmissionSettingsOwnProps) {
  let course = state.entities.courses[ownProps.courseID]
  let anonymousCourse = course && course.enabledFeatures.includes('anonymous_grading')
  let assignment = state.entities.assignments[ownProps.assignmentID].data
  let muted = assignment.muted
  let quiz = assignment.quiz_id && state.entities.quizzes[assignment.quiz_id]
  let anonymousQuiz = quiz && quiz.data && quiz.data.anonymous_submissions

  let anonymous = state.entities.assignments[ownProps.assignmentID].anonymousGradingOn || anonymousCourse || anonymousQuiz
  let disableAnonymous = anonymousCourse || anonymousQuiz || false

  return { anonymous, muted, assignment, disableAnonymous }
}
const Connect = connect(mapStateToProps, AssignmentActions)(SubmissionSettings)
export default (Connect: any)

const style = StyleSheet.create({
  container: {
    flex: 1,
  },
})
