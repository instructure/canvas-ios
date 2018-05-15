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

/**
 * @flow
 */

import React, { Component } from 'react'
import SubmissionGraph from '../../../submissions/SubmissionGraph'
import { connect } from 'react-redux'
import QuizSubmissionActions from '../actions'
import EnrollmentActions from '../../../enrollments/actions'
import AssignmentActions from '../../../assignments/actions'
import SubmissionListActions from '../../../submissions/list/actions'
import {
  View,
  StyleSheet,
  TouchableOpacity,
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
  refreshSubmissionSummary: Function,
  graded: number,
  ungraded: number,
  notSubmitted: number,
  pending: boolean,
}

export type QuizSubmissionBreakdownGraphSectionInitProps = {
  courseID: string,
  quizID: string,
  assignmentID?: ?string,
}

export class QuizSubmissionBreakdownGraphSection extends Component<QuizSubmissionBreakdownGraphSectionProps, any> {
  componentDidMount () {
    this.props.refreshQuizSubmissions(this.props.courseID, this.props.quizID, this.props.assignmentID)
    if (this.props.assignmentID) {
      this.props.refreshSubmissionSummary(this.props.courseID, this.props.assignmentID)
    } else {
      this.props.refreshEnrollments(this.props.courseID)
    }
  }

  componentWillReceiveProps (nextProps: QuizSubmissionBreakdownGraphSectionProps) {
    if (!this.props.assignmentID && nextProps.assignmentID) {
      this.props.refreshSubmissionSummary(this.props.courseID, nextProps.assignmentID)
    } else if (this.props.assignmentID && !nextProps.assignmentID) {
      this.props.refreshEnrollments(this.props.courseID)
    }
  }

  render () {
    let { graded, ungraded, notSubmitted, submissionTotalCount } = this.props
    let data = [graded, ungraded, notSubmitted]

    let gradedLabel = i18n('Graded')
    let ungradedLabel = i18n(`{
      count, plural,
        one {Needs Grading}
      other {Need Grading}
    }`, { count: ungraded })
    let notSubmittedLabel = i18n('Not Submitted')
    let labels = [gradedLabel, ungradedLabel, notSubmittedLabel]

    return (<View style={styles.container}>
      {data.map((item, index) =>
        <TouchableOpacity underlayColor='#eeeeee00' style={{ flex: 1 }} key={`quiz-submission_dial_highlight_${index}`}
          testID={`quiz-submission_dial_${index}`} onPress={() => this.onPress(index) }>
          <View>
            <SubmissionGraph label={labels[index]} total={submissionTotalCount || 0} current={data[index] || 0} key={index} pending={this.props.pending} />
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
        this.props.onPress('ungraded')
        break
      case notSubmitted:
        this.props.onPress('not_submitted')
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
  let submissionTotalCount = 0
  let graded = 0
  let ungraded = 0
  let notSubmitted = 0

  if (ownProps.assignmentID) {
    const assignment = state.entities.assignments[ownProps.assignmentID]
    if (assignment && assignment.submissionSummary && assignment.submissionSummary.data) {
      graded = assignment.submissionSummary.data.graded
      ungraded = assignment.submissionSummary.data.ungraded
      notSubmitted = assignment.submissionSummary.data.not_submitted
      submissionTotalCount = graded + ungraded + notSubmitted
      pending = pending || assignment.pending || assignment.submissionSummary.pending
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

  if (quiz && !ownProps.assignmentID) {
    quizSubmissions = quiz.quizSubmissions.refs.map((id) => {
      return state.entities.quizSubmissions[id]
    }).filter((a) => a)
    pending = quiz.quizSubmissions.pending
    graded = quizSubmissions.filter((s) => { return s.data.workflow_state === 'complete' }).length
    ungraded = quizSubmissions.filter((s) => { return s.data.workflow_state === 'pending_review' }).length
    notSubmitted = submissionTotalCount - (graded + ungraded)
  }

  return {
    submissionTotalCount,
    pending: Boolean(pending),
    graded,
    ungraded,
    notSubmitted,
  }
}

const Connected = connect(mapStateToProps, { ...QuizSubmissionActions, ...EnrollmentActions, ...AssignmentActions, ...SubmissionListActions })(QuizSubmissionBreakdownGraphSection)
export default (Connected: any)
