//
// Copyright (C) 2017-present Instructure, Inc.
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

type SubmissionSettingsOwnProps = {
  courseID: string,
  assignmentID: string,
  navigator: Navigator,
}
type SubmissionSettingsDataProps = {
  muted: boolean,
  assignment: Assignment,
}
type SubmissionSettingsActions = {
  updateAssignment: (string, Assignment, Assignment) => void,
}

type SubmissionSettingsProps =
  SubmissionSettingsOwnProps &
  SubmissionSettingsDataProps &
  SubmissionSettingsActions

export class SubmissionSettings extends PureComponent<SubmissionSettingsProps> {
  props: SubmissionSettingsProps

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
        </ScrollView>
      </Screen>
    )
  }
}

export function mapStateToProps (state: AppState, ownProps: SubmissionSettingsOwnProps) {
  const { assignmentID } = ownProps
  let assignment = state.entities.assignments[assignmentID].data
  let muted = assignment.muted

  return { muted, assignment }
}
const Connect = connect(mapStateToProps, AssignmentActions)(SubmissionSettings)
export default (Connect: any)

const style = StyleSheet.create({
  container: {
    flex: 1,
  },
})
