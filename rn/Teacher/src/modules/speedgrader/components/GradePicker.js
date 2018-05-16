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
  NativeModules,
} from 'react-native'
import i18n from 'format-message'
import { Heading1, Text } from '../../../common/text'
import { connect } from 'react-redux'
import SpeedGraderActions from '../actions'
import Images from '../../../images'
import colors from '../../../common/colors'
import branding from '../../../common/branding'
import { formatGradeText } from '../../../common/formatters'
import Slider from './Slider'

const PASS_FAIL = 'pass_fail'
const POINTS = 'points'
const PERCENTAGE = 'percent'
const LETTER = 'letter_grade'
const GPA = 'gpa_scale'
const NOT_GRADED = 'not_graded'

export class GradePicker extends Component<GradePickerProps, GradePickerState> {
  slider: ?Slider

  constructor (props: GradePickerProps) {
    super(props)

    let state: GradePickerState = {
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

  componentWillReceiveProps (nextProps: GradePickerProps) {
    if (this.state.originalRubricScore !== nextProps.rubricScore) {
      this.setState({ useCustomGrade: false, originalRubricScore: nextProps.rubricScore })
    }
    if (this.state.promptValue && this.props.pending && !nextProps.pending && !nextProps.grade) {
      this.setState({ promptValue: null })
      AlertIOS.alert(
        i18n('Error Saving Grade'),
        i18n('There was a problem saving the grade. Please try again.')
      )
    }
  }

  newCustomGrade = (promptValue: string) => {
    if (this.props.gradingType === 'percent') {
      let hasPercentage = promptValue[-1] === '%'
      promptValue = hasPercentage ? promptValue : promptValue + '%'
    }
    this.setState({ useCustomGrade: true, originalRubricScore: this.props.rubricScore, promptValue })
    this.props.gradeSubmission(this.props.courseID, this.props.assignmentID, this.props.userID, this.props.submissionID, promptValue)
  }

  excuseAssignment = () => {
    this.props.excuseAssignment(this.props.courseID, this.props.assignmentID, this.props.userID, this.props.submissionID)
  }

  openPrompt = () => {
    let buttons = [
      {
        text: i18n('No Grade'),
        onPress: () => {
          if (this.slider) {
            this.slider.moveTo(0, false)
          }
          this.newCustomGrade('')
        },
      },
      {
        text: i18n('OK'),
        onPress: (promptValue: string) => {
          if (this.slider) {
            this.slider.moveToScore(promptValue, false)
          }
          this.newCustomGrade(promptValue)
        },
      },
      {
        text: i18n('Cancel'),
      },
    ]
    if (!this.props.excused) {
      buttons.splice(1, 0, {
        text: i18n('Excuse Student'),
        onPress: () => {
          if (this.slider) {
            this.slider.moveTo(this.slider.width, false)
          }
          this.excuseAssignment()
        },
      })
    }
    let message = ''
    switch (this.props.gradingType) {
      case POINTS:
        message = i18n('Out of {points, number}', { points: this.props.pointsPossible })
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

    let grade = this.applyLatePolicy() ? this.props.enteredGrade : this.props.grade

    AlertIOS.prompt(
      i18n('Customize Grade'),
      message,
      buttons,
      'plain-text',
      this.props.excused ? i18n('Excused') : grade
    )

    NativeModules.AlertControls.onSubmitEditing((promptValue) => {
      this.newCustomGrade(promptValue)
      this.props.navigator.dismiss()
    })
  }

  togglePicker = () => {
    this.setState((previousState: GradePickerState, props: GradePickerProps) => {
      Animated.timing(
        this.state.easeAnimation,
        { toValue: previousState.pickerOpen ? 0 : 192 },
      ).start()

      return { pickerOpen: !previousState.pickerOpen }
    })
  }

  renderLatePolicy () {
    if (!this.applyLatePolicy() || !this.props.grade) return null
    const { pointsDeducted } = this.props
    let latePointsLabel = i18n({
      default: `{
        count, plural,
          one {# pt}
        other {# pts}
      }`,
      description: 'Number of points deducted.',
    }, { count: pointsDeducted })
    return [
      <View key='middle' style={styles.gradeCellMiddle}>
        <Text style={styles.orangeText}>{i18n('Late')}</Text>
        <Text style={styles.orangeText}>-{latePointsLabel}</Text>
      </View>,
      <View key='bottom' style={styles.gradeCellBottom}>
        <Heading1>{i18n('Final Grade')}</Heading1>
        { this.renderGrade() }
      </View>,
    ]
  }

  renderGrade = (latePolicy: boolean = false) => {
    let gradeToUse = latePolicy ? this.props.enteredGrade : this.props.grade
    let scoreToUse = latePolicy ? this.props.enteredScore : this.props.score

    let score = this.props.useRubricForGrading && !this.state.useCustomGrade ? this.props.rubricScore : scoreToUse
    let points = i18n(`{ score, number }/{ pointsPossible, number }`, { score, pointsPossible: this.props.pointsPossible })

    let grade = this.props.gradingType !== 'points' && formatGradeText(gradeToUse, this.props.gradingType)
    let result = grade ? `${points} (${grade})` : points
    return <Heading1 style={this.getButtonStyles(latePolicy)}>{result}</Heading1>
  }

  renderField = () => {
    if (this.props.gradingType === NOT_GRADED) {
      return <Heading1>{i18n('Not Graded')}</Heading1>
    } else if (this.props.pending) {
      return <ActivityIndicator />
    } else if (this.props.excused) {
      return <Heading1 style={this.getButtonStyles()}>{i18n('Excused')}</Heading1>
    } else if (this.props.grade) {
      return this.renderGrade(this.applyLatePolicy())
    } else {
      return <Image source={Images.add} style={styles.ungradedButton}/>
    }
  }

  changePassFailValue = (value: string) => {
    this.setState({ passFailValue: value })
    if (value === 'ex') {
      this.props.excuseAssignment(this.props.courseID, this.props.assignmentID, this.props.userID, this.props.submissionID)
    } else {
      this.props.gradeSubmission(this.props.courseID, this.props.assignmentID, this.props.userID, this.props.submissionID, value)
    }
  }

  getButtonStyles = (latePolicy: boolean = false) => {
    if (this.props.gradingType === PASS_FAIL && this.state.pickerOpen) {
      return { color: branding.primaryBrandColor }
    } else if (this.applyLatePolicy() && latePolicy) {
      return { color: colors.lightText }
    }
  }

  applyLatePolicy = () => {
    const { late, pointsDeducted } = this.props
    return !!(late && pointsDeducted && pointsDeducted > 0)
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
    let headingStyles = {}
    let cellStyles = styles.gradeCell
    if (this.applyLatePolicy()) {
      headingStyles = { color: colors.lightText }
      cellStyles = styles.gradeCellTop
    }
    return (
      <View style={styles.gradeCellContainer}>
        <View style={cellStyles}>
          <Heading1 style={headingStyles}>{i18n('Grade')}</Heading1>
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
        {this.renderLatePolicy()}
        {this.props.gradingType === POINTS && !this.props.useRubricForGrading &&
          <Slider
            {...this.props}
            score={this.applyLatePolicy() ? this.props.enteredScore : this.props.score}
            setScore={this.newCustomGrade}
            excuseAssignment={this.excuseAssignment}
            ref={(e) => { this.slider = e }}
          />
        }
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
  gradeCellContainer: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgray',
    paddingVertical: 12,
  },
  gradeCell: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  gradeCellTop: {
    paddingTop: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  gradeCellBottom: {
    paddingBottom: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  gradeCellMiddle: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 2,
    marginBottom: 8,
  },
  gradeButton: {
    minHeight: 20,
  },
  ungradedButton: {
    tintColor: colors.primaryButton,
  },
  orangeText: {
    fontSize: 14,
    color: '#FC5E13',
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
    late: submission.late,
    pointsDeducted: submission.points_deducted,
    enteredGrade: submission.entered_grade,
    enteredScore: submission.entered_score,
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
  navigator: Navigator,
  setScrollEnabled: (boolean) => void,
}

type GradePickerDataProps = {
  excused: boolean,
  grade: string,
  score: number,
  pending: boolean,
  gradingType: GradingType,
  pointsPossible: number,
  late?: boolean,
  pointsDeducted?: number,
  enteredGrade?: string,
  enteredScore?: number,
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
  promptValue?: ?string,
}
