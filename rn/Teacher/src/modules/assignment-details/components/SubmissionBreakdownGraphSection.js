/**
 * @flow
 */

import React, { Component } from 'react'
import SubmissionGraph from '../../submissions/SubmissionGraph'
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
  TouchableOpacity,
} from 'react-native'
import i18n from 'format-message'

type SubmissionBreakdownGraphSectionProps = {
  style: any,
  onPress: (string) => void,
} & SubmissionListProps

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

    let totalStudents = this.props.submissions.length
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

export function refreshSubmissionList (props: SubmissionListProps): void {
  props.refreshSubmissions(props.courseID, props.assignmentID)
  props.refreshEnrollments(props.courseID)
}

const Connected = connect(mapStateToProps, { ...SubmissionActions, ...EnrollmentActions })(SubmissionBreakdownGraphSection)
export default (Connected: any)
