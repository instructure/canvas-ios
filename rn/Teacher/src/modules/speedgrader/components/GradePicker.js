// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  AlertIOS,
  Image,
} from 'react-native'
import i18n from 'format-message'
import { Heading1 } from '../../../common/text'
import Button from 'react-native-button'
import { connect } from 'react-redux'
import SpeedGraderActions, { type SpeedGraderActionsType } from '../actions'
import Images from '../../../images'
import colors from '../../../common/colors'

export class GradePicker extends Component {
  props: GradePickerProps

  openPicker = () => {
    let buttons = [
      {
        text: i18n('Cancel'),
      },
      {
        text: i18n('Ok'),
      },
    ]
    if (this.props.submission && !this.props.submission.excused) {
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
      this.props.submission && this.props.submission.excused ? i18n('Excused') : ''
    )
  }

  renderGrade = () => {
    if (this.props.submission == null) {
      return <Heading1>TODO: No Submission</Heading1>
    } else if (this.props.submission.excused) {
      return <Heading1>{i18n('Excused')}</Heading1>
    } else if (this.props.submission.grade == null) {
      return <Image source={Images.add} style={styles.gradeButton}/>
    }
  }

  render () {
    return (
      <View style={styles.gradeCell}>
        <Heading1>{i18n('Grade')}</Heading1>
        <Button testID='grade-picker.button' style={styles.pickerButton} onPress={this.openPicker} accessibilityLabel={i18n('Customize Grade')}>
          {this.renderGrade()}
        </Button>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  gradeCell: {
    height: 48,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgray',
  },
  pickerButton: {
    minHeight: 20,
    paddingHorizontal: 20,
  },
  gradeButton: {
    tintColor: colors.primaryButton,
  },
})

export function mapStateToProps (state: AppState, ownProps: GradePickerOwnProps): GradePickerDataProps {
  const submission = ownProps.submissionID && state.entities.submissions[ownProps.submissionID]
    ? state.entities.submissions[ownProps.submissionID].submission
    : undefined
  return {
    submission,
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
  submission: ?SubmissionWithHistory,
}

type GradePickerProps = GradePickerOwnProps & GradePickerDataProps & SpeedGraderActionsType
