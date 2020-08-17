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

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  Image,
  TouchableHighlight,
  LayoutAnimation,
} from 'react-native'
import { Picker } from '@react-native-community/picker'
import { Text } from '../../../common/text'
import Images from '../../../images'
import type {
  SubmissionDataProps,
} from '../../submissions/list/submission-prop-types'
import { formattedDueDate } from '../../../common/formatters'
import SpeedGraderActions from '../actions'
import { colors, createStyleSheet } from '../../../common/stylesheet'

export class SubmissionPicker extends Component<SubmissionPickerProps, State> {
  state: State = {
    showingPicker: false,
  }

  _togglePicker = () => {
    LayoutAnimation.easeInEaseOut()
    const showingPicker = !this.state.showingPicker
    this.setState({ showingPicker })
  }

  changeSelectedSubmission = (index: number) => {
    if (this.props.submissionID) {
      this.props.selectSubmissionFromHistory(this.props.submissionID, index)
      this._togglePicker()
    }
  }

  hasSubmission () {
    let stati = ['none', 'missing']
    return !stati.includes(this.props.submissionProps.status) && !!this.props.submissionProps.submission
  }

  render () {
    const submission = this.props.submissionProps.submission
    if (!this.hasSubmission()) return <View style={[styles.container, styles.noSub]} />

    if (submission && submission.submission_history &&
      submission.submission_history.length > 1) {
      let selected = submission
      let index = this.props.selectedIndex
      if (index != null) {
        selected = submission.submission_history[index]
      } else {
        index = submission.submission_history.length - 1
      }
      return <View style={styles.container}>
        <TouchableHighlight
          underlayColor={colors.backgroundLightest}
          onPress={this._togglePicker}
          testID='header.toggle-submission_history-picker'
          accessibilityTraits='button'
        >
          <View style={styles.submissionHistoryContainer}>
            <Text style={[styles.submissionDate, this.state.showingPicker && { color: colors.primary }]}>
              {formattedDueDate(new Date((selected && selected.submitted_at) || ''))}
            </Text>
            <Image source={Images.pickerArrow} style={[{ alignSelf: 'center' }, this.state.showingPicker && styles.arrowSelecting]} />
          </View>
        </TouchableHighlight>
        { this.state.showingPicker &&
          <Picker
            selectedValue={index}
            onValueChange={this.changeSelectedSubmission}
            testID='header.picker'
          >
            {submission.submission_history.map((sub, idx) => (
              <Picker.Item
                key={sub.id}
                value={idx}
                label={formattedDueDate(new Date(sub.submitted_at || ''))}
              />
            ))}
          </Picker>
        }
      </View>
    } else {
      if (!submission) return <View style={[styles.submissionHistoryContainer, styles.noSub]} />
      return (
        <View style={styles.container}>
          <View style={styles.submissionHistoryContainer}>
            <Text style={styles.submissionDate}>
              {formattedDueDate(new Date(submission.submitted_at || ''))}
            </Text>
          </View>
        </View>
      )
    }
  }
}

const styles = createStyleSheet((colors, vars) => ({
  container: {
    marginTop: 16,
    paddingHorizontal: 16,
    borderBottomColor: colors.borderMedium,
    borderBottomWidth: vars.hairlineWidth,
    borderStyle: 'solid',
    paddingBottom: 4,
  },
  noSub: {
    paddingBottom: 21,
  },
  submissionHistoryContainer: {
    flex: 0,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  submissionDate: {
    color: colors.textDark,
    fontSize: 14,
    fontWeight: '500',
  },
  arrowSelecting: {
    transform: [
      { rotate: '180deg' },
    ],
  },
}))

export function mapStateToProps (state: AppState, ownProps: RouterProps): SubmissionPickerDataProps {
  if (!ownProps.submissionID) {
    return {
      selectedIndex: null,
    }
  }

  return {
    selectedIndex: state.entities.submissions[ownProps.submissionID]?.selectedIndex,
  }
}

let Connected = connect(mapStateToProps, SpeedGraderActions)(SubmissionPicker)
export default (Connected: any)

type RouterProps = {
  submissionID: ?string,
  submissionProps: SubmissionDataProps,
}

type State = {
  showingPicker: boolean,
}

type SubmissionPickerDataProps = {
  selectedIndex: ?number,
}

type SubmissionPickerActionProps = {
  selectSubmissionFromHistory: Function,
}

type SubmissionPickerProps
  = RouterProps
  & SubmissionPickerDataProps
  & SubmissionPickerActionProps
