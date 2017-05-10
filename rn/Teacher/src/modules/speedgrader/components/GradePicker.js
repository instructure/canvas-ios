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
} from 'react-native'
import i18n from 'format-message'
import { Heading1 } from '../../../common/text'
import Button from 'react-native-button'
import { connect } from 'react-redux'
import SpeedGraderActions from '../actions'
import Images from '../../../images'
import colors from '../../../common/colors'
import branding from '../../../common/branding'

const PASS_FAIL = 'pass_fail'
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
    }

    if (this.props.gradingType === PASS_FAIL) {
      state.passFailValue = this.props.excused ? 'ex' : this.props.grade
    }

    this.state = state
  }

  openPrompt = () => {
    let buttons = [
      {
        text: i18n('Cancel'),
      },
      {
        text: i18n('Ok'),
        onPress: (promptValue) => {
          if (this.props.gradingType === 'percent') {
            let hasPercentage = promptValue[-1] === '%'
            promptValue = hasPercentage ? promptValue : promptValue + '%'
          }
          this.props.gradeSubmission(this.props.courseID, this.props.assignmentID, this.props.userID, this.props.submissionID, promptValue)
        },
      },
    ]
    if (!this.props.excused) {
      buttons.unshift({
        text: i18n('Excuse Student'),
        onPress: () => this.props.excuseAssignment(this.props.courseID, this.props.assignmentID, this.props.userID, this.props.submissionID),
      })
    }

    AlertIOS.prompt(
      i18n('Customize Grade'),
      null,
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
    let points = `${this.props.score}/${this.props.pointsPossible}`
    let grade = this.props.gradingType === 'points' ? '' : `${this.props.grade} `
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

  render () {
    let gradeButton = this.props.gradingType === PASS_FAIL ? this.togglePicker : this.openPrompt
    return (
      <View style={styles.gradePicker}>
          <View style={styles.gradeCell}>
          <Heading1>{i18n('Grade')}</Heading1>
          <Button
            testID='grade-picker.button'
            style={styles.gradeButton}
            onPress={gradeButton}
            accessibilityLabel={i18n('Customize Grade')}
            disabled={this.props.pending || this.props.gradingType === 'not_graded'}
          >
            {this.renderField()}
          </Button>
        </View>
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
    paddingVertical: 9,
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
}
