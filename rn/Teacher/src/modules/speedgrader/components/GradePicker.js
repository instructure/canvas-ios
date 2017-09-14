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
import {
  View,
  StyleSheet,
  AlertIOS,
  Image,
  ActivityIndicator,
  PickerIOS,
  Animated,
  TouchableOpacity,
} from 'react-native'
import i18n from 'format-message'
import { Heading1, Text } from '../../../common/text'
import { connect } from 'react-redux'
import SpeedGraderActions from '../actions'
import Images from '../../../images'
import colors from '../../../common/colors'
import branding from '../../../common/branding'
import { formatGradeText } from '../../../common/formatters'

const PASS_FAIL = 'pass_fail'
const POINTS = 'points'
const PERCENTAGE = 'percent'
const LETTER = 'letter_grade'
const GPA = 'gpa_scale'
const NOT_GRADED = 'not_graded'

export class GradePicker extends Component {
  props: GradePickerProps
  state: GradePickerState

  constructor (props: GradePickerProps) {
    super(props)

    let state = {
      passFailValue: '',
      pickerOpen: false,
      easeAnimation: new Animated.Value(0),
      useCustomGrade: true,
      originalRubricScore: this.props.rubricScore,
    }

    if (this.props.gradingType === PASS_FAIL) {
      state.passFailValue = this.props.excused ? 'ex' : this.props.grade
    }

    this.state = state
  }

  openPrompt = () => {
    let buttons = [
      {
        text: i18n('OK'),
        onPress: (promptValue) => {
          if (this.props.gradingType === 'percent') {
            let hasPercentage = promptValue[-1] === '%'
            promptValue = hasPercentage ? promptValue : promptValue + '%'
          }
          this.setState({ useCustomGrade: true, originalRubricScore: this.props.rubricScore })
          this.props.gradeSubmission(this.props.courseID, this.props.assignmentID, this.props.userID, this.props.submissionID, promptValue)
        },
      },
      {
        text: i18n('Cancel'),
      },
    ]
    if (!this.props.excused) {
      buttons.unshift({
        text: i18n('Excuse Student'),
        onPress: () => this.props.excuseAssignment(this.props.courseID, this.props.assignmentID, this.props.userID, this.props.submissionID),
      })
    }
    let message = ''
    switch (this.props.gradingType) {
      case POINTS:
        message = i18n('Out of {points}', { points: this.props.pointsPossible })
        break
      case PERCENTAGE:
        message = i18n('Percent (%)')
        break
      case GPA:
        message = i18n('GPA')
        break
      case LETTER:
        message = i18n('Letter grade')
        break
    }

    AlertIOS.prompt(
      i18n('Customize Grade'),
      message,
      buttons,
      'plain-text',
      this.props.excused ? i18n('Excused') : this.props.grade
    )
  }

  togglePicker = () => {
    this.setState((previousState: GradePickerState, props: GradePickerProps) => {
      if (previousState.pickerOpen) {
        if (this.state.passFailValue === 'ex') {
          props.excuseAssignment(this.props.courseID, this.props.assignmentID, this.props.userID, this.props.submissionID)
        } else {
          props.gradeSubmission(this.props.courseID, this.props.assignmentID, this.props.userID, this.props.submissionID, this.state.passFailValue)
        }
      }

      Animated.timing(
        this.state.easeAnimation,
        { toValue: previousState.pickerOpen ? 0 : 192 },
      ).start()

      return { pickerOpen: !previousState.pickerOpen }
    })
  }

  renderGrade = () => {
    if (this.state.originalRubricScore !== this.props.rubricScore) {
      this.setState({ useCustomGrade: false, originalRubricScore: this.props.rubricScore })
    }

    let score = this.props.useRubricForGrading && !this.state.useCustomGrade ? this.props.rubricScore : this.props.score
    let points = i18n(`{ score, number }/{ pointsPossible, number }`, { score, pointsPossible: this.props.pointsPossible })
    let grade = this.props.gradingType === 'points' ? '' : `${formatGradeText(this.props.grade, this.props.gradingType)} `
    return <Heading1 style={this.getButtonStyles()}>{grade}{points}</Heading1>
  }

  renderField = () => {
    if (this.props.gradingType === NOT_GRADED) {
      return <Heading1>{i18n('Not Graded')}</Heading1>
    } else if (this.props.pending) {
      return <ActivityIndicator />
    } else if (this.props.excused) {
      return <Heading1 style={this.getButtonStyles()}>{i18n('Excused')}</Heading1>
    } else if (this.props.grade) {
      return this.renderGrade()
    } else {
      return <Image source={Images.add} style={styles.ungradedButton}/>
    }
  }

  changePassFailValue = (value: string) => {
    this.setState({ passFailValue: value })
  }

  getButtonStyles = () => {
    if (this.props.gradingType === PASS_FAIL && this.state.pickerOpen) {
      return { color: branding.primaryBrandColor }
    }
  }

  renderModeratedGradingUnsuported () {
    return (
      <View style={styles.gradeCell}>
        <Text
          style={{
            fontSize: 14,
          }}
        >
          {i18n('Moderated Grading Unsupported')}
        </Text>
      </View>
    )
  }

  renderGradeCell () {
    let disabled = (this.props.pending || this.props.gradingType === 'not_graded')
    let gradeButtonAction = !disabled ? (this.props.gradingType === PASS_FAIL ? this.togglePicker : this.openPrompt) : null
    return (
      <View style={styles.gradeCell}>
        <Heading1>{i18n('Grade')}</Heading1>
        <TouchableOpacity
            testID='grade-picker.button'
            style={styles.gradeButton}
            onPress={gradeButtonAction}
            accessibilityTraits='button'
            accessibilityLabel={i18n('Customize Grade')}
            activeOpacity={disabled ? 1 : 0.2}
          >
            {this.renderField()}
          </TouchableOpacity>
      </View>
    )
  }

  render () {
    return (
      <View style={styles.gradePicker}>
        {this.props.isModeratedGrading
          ? this.renderModeratedGradingUnsuported()
          : this.renderGradeCell()
        }
        {this.props.gradingType === PASS_FAIL &&
          <Animated.View
            style={{ height: this.state.easeAnimation, overflow: 'hidden' }}
          >
            <PickerIOS
              selectedValue={this.state.passFailValue}
              onValueChange={this.changePassFailValue}
            >
              <PickerIOS.Item
                key='none'
                value=''
                label='---'
              />
              <PickerIOS.Item
                key='pass'
                value='complete'
                label={i18n('Complete')}
              />
              <PickerIOS.Item
                key='fail'
                value='incomplete'
                label={i18n('Incomplete')}
              />
              <PickerIOS.Item
                key='excuse'
                value='ex'
                label={i18n('Excuse Student')}
              />
            </PickerIOS>
          </Animated.View>
        }
      </View>
    )
  }
}

const styles = StyleSheet.create({
  gradePicker: {
    paddingHorizontal: 16,
  },
  gradeCell: {
    paddingVertical: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgray',
  },
  gradeButton: {
    minHeight: 20,
    paddingHorizontal: 20,
  },
  ungradedButton: {
    tintColor: colors.primaryButton,
  },
})

export function mapStateToProps (state: AppState, ownProps: GradePickerOwnProps): GradePickerDataProps {
  let assignment = state.entities.assignments[ownProps.assignmentID].data
  if (!ownProps.submissionID) {
    return {
      excused: false,
      grade: '',
      pending: false,
      score: 0,
      pointsPossible: assignment.points_possible,
      gradingType: assignment.grading_type,
    }
  }

  let submission = state.entities.submissions[ownProps.submissionID].submission
  return {
    excused: submission.excused,
    grade: submission.grade || '',
    score: submission.score,
    pending: Boolean(state.entities.submissions[ownProps.submissionID].pending),
    gradingType: assignment.grading_type,
    pointsPossible: assignment.points_possible,
  }
}

const Connected = connect(mapStateToProps, SpeedGraderActions)(GradePicker)
export default (Connected: any)

type GradePickerOwnProps = {
  submissionID: ?string,
  courseID: string,
  assignmentID: string,
  userID: string,
  isModeratedGrading: boolean,
  rubricScore: string,
  useRubricForGrading: boolean,
}

type GradePickerDataProps = {
  excused: boolean,
  grade: string,
  score: number,
  pending: boolean,
  gradingType: 'pass_fail' | 'percent' | 'letter_grade' | 'gpa_scale' | 'points' | 'not_graded',
  pointsPossible: number,
}

type GradePickerActionProps = {
  excuseAssignment: Function,
  gradeSubmission: Function,
}

type GradePickerProps = GradePickerOwnProps & GradePickerDataProps & GradePickerActionProps

type GradePickerState = {
  passFailValue: string,
  pickerOpen: boolean,
  easeAnimation: Animated.Value,
  useCustomGrade: boolean,
  originalRubricScore: string,
}
