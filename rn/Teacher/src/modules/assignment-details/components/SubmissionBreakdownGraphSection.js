/**
 * @flow
 */

import React, { Component } from 'react'
import SubmissionGraph from '../../submissions/SubmissionGraph'
import { connect } from 'react-redux'
import SubmissionActions from '../../submissions/list/actions'
import AssignmentActions from '../../assignments/actions'
import { gradeProp } from '../../submissions/list/get-submissions-props'
import {
  View,
  StyleSheet,
  ActivityIndicator,
  LayoutAnimation,
  TouchableOpacity,
} from 'react-native'
import i18n from 'format-message'

export type SubmissionBreakdownGraphSectionProps = {
  courseID: string,
  assignmentID: string,
  style: any,
  onPress: (string) => void,
  refreshSubmissions: Function,
  refreshGradeableStudents: Function,
  refreshAssignment: Function,
  submissionTotalCount: number,
  submissions: Submission[],
}

export type SubmissionBreakdownGraphSectionInitProps = {
  courseID: string,
  assignmentID: string,
}

export class SubmissionBreakdownGraphSection extends Component<any, SubmissionBreakdownGraphSectionProps, any> {
  componentDidMount () {
    refreshSubmissionList(this.props)
  }

  componentWillUpdate () {
    LayoutAnimation.easeInEaseOut()
  }

  render (): ReactElement<*> {
    let gradedLabel = i18n('Graded')

    let ungradedLabel = i18n('Ungraded')

    let notSubmittedLabel = i18n('Not Submitted')

    let labels = [gradedLabel, ungradedLabel, notSubmittedLabel]

    if (this.props.pending || !this.props.submissions) {
      return <View style={style.loadingWrapper}><ActivityIndicator /></View>
    }

    let totalStudents = this.props.submissionTotalCount
    let graded = this.props.submissions.filter((s) => { return s.grade !== 'not_submitted' && s.grade !== 'ungraded' }).length
    let ungraded = this.props.submissions.filter((s) => { return s.grade === 'ungraded' }).length
    let notSubmitted = this.props.submissions.filter((s) => s.grade === 'not_submitted').length

    let data = [graded, ungraded, notSubmitted]

    return (
      <View style={[style.container, this.props.style]}>
        {data.map((item, index) =>
          <TouchableOpacity underlayColor='#eeeeee00' style={style.common} key={`submission_dial_highlight_${index}`}
                              testID={`submission_dial_${index}`} onPress={() => this.onPress(index) }>
            <View>
              <SubmissionGraph label={labels[index]} total={totalStudents} current={data[index]} key={index}/>
            </View>
          </TouchableOpacity>
        )}
      </View>
    )
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

const style = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
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

export function refreshSubmissionList (props: SubmissionBreakdownGraphSectionProps): void {
  props.refreshSubmissions(props.courseID, props.assignmentID)
  props.refreshGradeableStudents(props.courseID, props.assignmentID)
  props.refreshAssignment(props.courseID, props.assignmentID)
}

export function mapStateToProps (state: AppState, ownProps: SubmissionBreakdownGraphSectionInitProps): any {
  const assignment = state.entities.assignments[ownProps.assignmentID]
  let submissions = []
  let pending = false
  if (assignment) {
    submissions = assignment.submissions.refs.map((id) => {
      const submission = state.entities.submissions[id].submission
      if (!submission) return null
      return {
        ...submission,
        grade: gradeProp(submission),
      }
    }).filter((a) => a)
    pending = assignment.pending || assignment.submissions.pending
  } else {
    pending = true
  }

  let submissionTotalCount = 0

  if (assignment && assignment.gradeableStudents) {
    submissionTotalCount = assignment.gradeableStudents.refs.length
    pending = pending || assignment.gradeableStudents.pending
  } else {
    pending = true
  }

  return {
    submissions,
    submissionTotalCount,
    pending,
  }
}

const Connected = connect(mapStateToProps, { ...SubmissionActions, ...AssignmentActions })(SubmissionBreakdownGraphSection)
export default (Connected: any)
