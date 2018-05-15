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
  Image,
  TouchableHighlight,
  PickerIOS,
  LayoutAnimation,
} from 'react-native'
import { Text } from '../../../common/text'
import Images from '../../../images'
import type {
  SubmissionDataProps,
} from '../../submissions/list/submission-prop-types'
import { formattedDueDate } from '../../../common/formatters'
import SpeedGraderActions from '../actions'
import brand from '../../../common/branding'

var PickerItemIOS = PickerIOS.Item

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
          underlayColor='white'
          onPress={this._togglePicker}
          testID='header.toggle-submission_history-picker'
          accessibilityTraits='button'
        >
          <View style={styles.submissionHistoryContainer}>
            <Text style={[styles.submissionDate, this.state.showingPicker && { color: brand.primaryBrandColor }]}>
              {formattedDueDate(new Date((selected && selected.submitted_at) || ''))}
            </Text>
            <Image source={Images.pickerArrow} style={[{ alignSelf: 'center' }, this.state.showingPicker && styles.arrowSelecting]} />
          </View>
        </TouchableHighlight>
        { this.state.showingPicker &&
          <PickerIOS
            selectedValue={index}
            onValueChange={this.changeSelectedSubmission}
            testID='header.picker'
          >
            {submission.submission_history.map((sub, idx) => (
              <PickerItemIOS
                key={sub.id}
                value={idx}
                label={formattedDueDate(new Date(sub.submitted_at || ''))}
              />
            ))}
          </PickerIOS>
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

const styles = StyleSheet.create({
  container: {
    marginTop: 16,
    marginHorizontal: 16,
    borderBottomColor: '#D8D8D8',
    borderBottomWidth: StyleSheet.hairlineWidth,
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
    color: '#8B969E',
    fontSize: 14,
    fontWeight: '500',
  },
  arrowSelecting: {
    transform: [
      { rotate: '180deg' },
    ],
  },
})

export function mapStateToProps (state: AppState, ownProps: RouterProps): SubmissionPickerDataProps {
  if (!ownProps.submissionID) {
    return {
      selectedIndex: null,
    }
  }

  return {
    selectedIndex: state.entities.submissions[ownProps.submissionID].selectedIndex,
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
