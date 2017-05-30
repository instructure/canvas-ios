/**
 * @flow
 */

import React, { Component } from 'react'
import SubmissionGraph from '../../../submissions/SubmissionGraph'
import { connect } from 'react-redux'
import QuizSubmissionActions from '../actions'
import EnrollmentActions from '../../../enrollments/actions'
import AssignmentActions from '../../../assignments/actions'
import {
  View,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
  LayoutAnimation,
} from 'react-native'
import i18n from 'format-message'

export type QuizSubmissionBreakdownGraphSectionProps = {
  courseID: string,
  quizID: string,
  assignmentID?: ?string,
  style: any,
  onPress: (string) => void,
  refreshQuizSubmissions: Function,
  refreshEnrollments: Function,
  refreshGradeableStudents: Function,
  refreshAssignment: Function,
  submissionTotalCount: number,
  quizSubmissions: QuizSubmissionState[],
}

export type QuizSubmissionBreakdownGraphSectionInitProps = {
  courseID: string,
  quizID: string,
  assignmentID?: ?string,
}

export class QuizSubmissionBreakdownGraphSection extends Component<any, QuizSubmissionBreakdownGraphSectionProps, any> {

  componentDidMount () {
    this.props.refreshQuizSubmissions(this.props.courseID, this.props.quizID)
    if (this.props.assignmentID) {
      this.props.refreshAssignment(this.props.courseID, this.props.assignmentID)
      this.props.refreshGradeableStudents(this.props.courseID, this.props.assignmentID)
    } else {
      this.props.refreshEnrollments(this.props.courseID)
    }
  }

  componentWillUpdate () {
    LayoutAnimation.easeInEaseOut()
  }

  render () {
    if (this.props.pending) {
      return (<View style={styles.loadingWrapper}>
                <ActivityIndicator />
             </View>)
    }

    let gradedLabel = i18n('Graded')

    let ungradedLabel = i18n('Ungraded')

    let notSubmittedLabel = i18n('Not Submitted')

    let labels = [gradedLabel, ungradedLabel, notSubmittedLabel]

    if (this.props.pending || !this.props.quizSubmissions) {
      return <View style={styles.loadingWrapper}><ActivityIndicator /></View>
    }

    let total = this.props.submissionTotalCount
    let graded = this.props.quizSubmissions.filter((s) => { return s.data.workflow_state === 'complete' }).length
    let ungraded = this.props.quizSubmissions.filter((s) => { return s.data.workflow_state === 'pending_review' }).length
    let notSubmitted = total - (graded + ungraded)

    let data = [graded, ungraded, notSubmitted]

    return (<View style={styles.container}>
              {data.map((item, index) =>
                <TouchableOpacity underlayColor='#eeeeee00' style={{ flex: 1 }} key={`quiz-submission_dial_highlight_${index}`}
                                    testID={`quiz-submission_dial_${index}`} onPress={() => this.onPress(index) }>
                  <View>
                    <SubmissionGraph label={labels[index]} total={total} current={data[index]} key={index}/>
                  </View>
                </TouchableOpacity>
              )}
            </View>)
  }

  onPress (itemIndex: number) {
    let graded = 0
    let ungraded = 1
    let notSubmitted = 2

    if (!this.props.onPress) return

    switch (itemIndex) {
      case graded:
        this.props.onPress('graded')
        break
      case ungraded:
        this.props.onPress('notgraded')
        break
      case notSubmitted:
        this.props.onPress('notsubmitted')
        break
    }
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginRight: 40,
    marginTop: global.style.defaultPadding / 2,
  },
  loadingWrapper: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  common: {
    flex: 1,
  },
})

export function mapStateToProps (state: AppState, ownProps: QuizSubmissionBreakdownGraphSectionInitProps): any {
  const quiz = state.entities.quizzes[ownProps.quizID]
  let quizSubmissions = []
  let pending = false
  if (quiz) {
    quizSubmissions = quiz.quizSubmissions.refs.map((id) => {
      return state.entities.quizSubmissions[id]
    }).filter((a) => a)
    pending = quiz.quizSubmissions.pending
  }

  let submissionTotalCount = 0

  if (ownProps.assignmentID) {
    const assignment = state.entities.assignments[ownProps.assignmentID]
    if (assignment && assignment.gradeableStudents) {
      submissionTotalCount = assignment.gradeableStudents.refs.length
      pending = pending || assignment.pending || assignment.gradeableStudents.pending
    } else {
      pending = true
    }
  } else {
    const course = state.entities.courses[ownProps.courseID]
    if (course) {
      submissionTotalCount = course.enrollments.refs.map((r) => {
        return state.entities.enrollments[r]
      })
      .filter((r) => r)
      .filter((r) => r.type === 'StudentEnrollment')
      .length
      pending = pending || course.enrollments.pending
    }
  }

  return {
    quizSubmissions,
    submissionTotalCount,
    pending,
  }
}

const Connected = connect(mapStateToProps, { ...QuizSubmissionActions, ...EnrollmentActions, ...AssignmentActions })(QuizSubmissionBreakdownGraphSection)
export default (Connected: any)
