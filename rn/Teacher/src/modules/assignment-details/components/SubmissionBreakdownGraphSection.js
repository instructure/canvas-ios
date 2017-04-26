/**
 * @flow
 */

import React, { Component } from 'react'
import SubmissionGraph from './SubmissionGraph'
import { connect } from 'react-redux'
import { mapStateToProps } from '../../submissions/list/map-state-to-props'
import type {
  SubmissionListProps,
} from '../../submissions/list/submission-prop-types'
import SubmissionActions from '../../submissions/list/actions'
import EnrollmentActions from '../../enrollments/actions'
import {
  View,
  StyleSheet,
  ActivityIndicator,
  LayoutAnimation,
} from 'react-native'
import i18n from 'format-message'

type SubmissionBreakdownGraphSectionProps = {
  style: any,
} & SubmissionListProps

export class SubmissionBreakdownGraphSection extends Component<any, SubmissionBreakdownGraphSectionProps, any> {
  componentDidMount () {
    refreshSubmissionList(this.props)
  }

  render (): ReactElement<*> {
    let gradedLabel = i18n({
      default: 'Graded',
      description: 'Assignment Details submissions graph `graded`',
    })

    let ungradedLabel = i18n({
      default: 'Ungraded',
      description: 'Assignment Details submissions graph `graded`',
    })

    let notSubmittedLabel = i18n({
      default: 'Not Submitted',
      description: 'Assignment Details submissions graph `graded`',
    })

    let labels = [gradedLabel, ungradedLabel, notSubmittedLabel]

    if (this.props.pending || !this.props.submissions) {
      return <View style={style.loadingWrapper}><ActivityIndicator /></View>
    }

    let totalStudents = this.props.submissions.length
    let graded = this.props.submissions.filter((s) => { return s.grade !== 'not_submitted' && s.grade !== 'ungraded' }).length
    let ungraded = this.props.submissions.filter((s) => { return s.grade === 'ungraded' }).length
    let notSubmitted = this.props.submissions.filter((s) => s.grade === 'not_submitted').length

    let data = [graded, ungraded, notSubmitted]

    LayoutAnimation.easeInEaseOut()
    return (
      <View style={[style.container, this.props.style]}>
        {data.map((item, index) =>
          <SubmissionGraph label={labels[index]} total={totalStudents} data={data[index]} key={index}/>
        )}
      </View>
    )
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
})

export function refreshSubmissionList (props: SubmissionListProps): void {
  props.refreshSubmissions(props.courseID, props.assignmentID)
  props.refreshEnrollments(props.courseID)
}

const Connected = connect(mapStateToProps, { ...SubmissionActions, ...EnrollmentActions })(SubmissionBreakdownGraphSection)
export default (Connected: any)
