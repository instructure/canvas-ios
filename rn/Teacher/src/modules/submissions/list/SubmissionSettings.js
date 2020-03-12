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
  ScrollView,
  StyleSheet,
} from 'react-native'
import Screen from '../../../routing/Screen'
import i18n from 'format-message'
import RowWithSwitch from '../../../common/components/rows/RowWithSwitch'
import RowSeparator from '../../../common/components/rows/RowSeparator'
import { graphql } from 'react-apollo'
import gql from 'graphql-tag'

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
    this.props.mutate({
      variables: {
        id: this.props.assignmentID,
        muted: value,
      },
      optimisticResponse: {
        updateAssignment: {
          assignment: {
            id: this.props.id,
            muted: value,
            __typename: 'Assignment',
          },
          __typename: 'UpdateAssignmentPayload',
        },
      },
    })
  }

  render () {
    return (
      <Screen
        title={i18n('Submission Settings')}
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

const SubmissionSettingsWithMutation = graphql(gql`
mutation ($id: ID!, $muted: Boolean!) {
  updateAssignment(input: { id: $id, muted: $muted }) {
    assignment {
      id
      muted
    }
  }
}
`)(SubmissionSettings)

export default graphql(gql`
query ($id: ID!) {
  assignment(id: $id) {
    id
    muted
  }
}
`, {
  options: (props) => ({
    variables: {
      id: props.assignmentID,
    },
  }),
  props: (props) => ({
    muted: props.data.assignment?.muted ?? false,
    id: props.data.assignment?.id,
  }),
})(SubmissionSettingsWithMutation)

const style = StyleSheet.create({
  container: {
    flex: 1,
  },
})
