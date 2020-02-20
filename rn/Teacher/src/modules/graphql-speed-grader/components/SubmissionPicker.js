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
import {
  View,
  Image,
  TouchableHighlight,
  PickerIOS,
  LayoutAnimation,
} from 'react-native'
import { Text } from '../../../common/text'
import type {
  SubmissionDataProps,
} from '../../submissions/list/submission-prop-types'
import { formattedDueDate } from '../../../common/formatters'
import icon from '../../../images/inst-icons'
import { colors, createStyleSheet } from '../../../common/stylesheet'

var PickerItemIOS = PickerIOS.Item

export default class SubmissionPicker extends Component<SubmissionPickerProps, State> {
  state: State = {
    showingPicker: false,
  }

  _togglePicker = () => {
    LayoutAnimation.easeInEaseOut()
    const showingPicker = !this.state.showingPicker
    this.setState({ showingPicker })
  }

  changeSelectedSubmission = (index: number) => {
    this.props.selectSubmissionFromHistory(index)
    this._togglePicker()
  }

  hasSubmission () {
    return (
      this.props.submission.missing === false &&
      this.props.submission.state !== 'unsubmitted'
    )
  }

  render () {
    const submission = this.props.submission
    if (!this.hasSubmission()) return <View style={[styles.container, styles.noSub]} />

    if (submission && submission.submissionHistory &&
      submission.submissionHistory.edges.length > 1) {
      let selected = submission.submissionHistory.edges[this.props.selectedIndex].submission
      return <View style={styles.container}>
        <TouchableHighlight
          underlayColor={colors.backgroundLightest}
          onPress={this._togglePicker}
          testID='header.toggle-submission_history-picker'
          accessibilityTraits='button'
        >
          <View style={styles.submissionHistoryContainer}>
            <Text style={[styles.submissionDate, this.state.showingPicker && { color: colors.primary }]}>
              {formattedDueDate(new Date((selected && selected.submittedAt) || ''))}
            </Text>
            <Image source={icon('miniArrowDown', 'line')} style={[styles.arrow, this.state.showingPicker && styles.arrowSelecting]} />
          </View>
        </TouchableHighlight>
        { this.state.showingPicker &&
          <PickerIOS
            selectedValue={this.props.selectedIndex}
            onValueChange={this.changeSelectedSubmission}
            testID='header.picker'
          >
            {submission.submissionHistory.edges.map(({ submission: sub }, idx) => (
              <PickerItemIOS
                key={sub.id}
                value={idx}
                label={formattedDueDate(new Date(sub.submittedAt || ''))}
              />
            ))}
          </PickerIOS>
        }
      </View>
    } else {
      if (submission.state === 'unsubmitted') return <View style={[styles.submissionHistoryContainer, styles.noSub]} />
      return (
        <View style={styles.container}>
          <View style={styles.submissionHistoryContainer}>
            <Text style={styles.submissionDate}>
              {formattedDueDate(new Date(submission.submittedAt || ''))}
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
  arrow: {
    alignSelf: 'center',
    width: 16,
    height: 10,
    tintColor: colors.textDark,
  },
  arrowSelecting: {
    transform: [
      { rotate: '180deg' },
    ],
  },
}))

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
