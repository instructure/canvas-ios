/**
 * @flow
 */

import React, { Component } from 'react'
import SubmissionGraph from '../../submissions/SubmissionGraph'
import { connect } from 'react-redux'
import SubmissionActions from '../../submissions/list/actions'

import {
  View,
  StyleSheet,
  ActivityIndicator,
  LayoutAnimation,
  TouchableOpacity,
  Text,
} from 'react-native'
import i18n from 'format-message'

export type SubmissionBreakdownGraphSectionProps = {
  courseID: string,
  assignmentID: string,
  style: any,
  onPress: (string) => void,
  graded: number,
  ungraded: number,
  not_submitted: number,
  submissionTotalCount: number,
  refreshSubmissionSummary: Function,
  submissionTypes: string[],
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

  renderNoSubmissions () {
    let noSubmissionsMessage = i18n('Tap to view submissions list.')
    return (
        <View style={[style.container, this.props.style]} accessible={false}>
          <View style={style.paperOnlyContainer} accessible={false} accessibilityLabel={noSubmissionsMessage}>
            <View style={style.paperOnlyContainer}>
              <TouchableOpacity underlayColor='#eeeeee00' style={style.common}
                                key={`submission_dial_highlight_no_submissions`}
                                testID={`assignment-details.submission-breakdown-graph-section.no-submissions`}
                                onPress={() => this.props.onPress('') } accessible={false}>
                <Text style={style.paperOnlyContainerLabel} accessible={false}>{noSubmissionsMessage}</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
    )
  }

  render () {
    let gradedLabel = i18n('Graded')

    let ungradedLabel = i18n('Ungraded')

    let notSubmittedLabel = i18n('Not Submitted')

    let labels = [gradedLabel, ungradedLabel, notSubmittedLabel]

    let ids = ['graded', 'ungraded', 'not-submitted']

    if (this.props.pending) {
      return <View style={style.loadingWrapper}><ActivityIndicator /></View>
    }

    let totalStudents = this.props.submissionTotalCount
    let graded = this.props.graded
    let ungraded = this.props.ungraded
    let notSubmitted = this.props.not_submitted
    let submissionTypes = this.props.submissionTypes || []

    let noSubmissions = submissionTypes.includes('none')
    if (noSubmissions) { return this.renderNoSubmissions() }

    let paperOnly = submissionTypes.includes('on_paper')
    let paperOnlyMessage = i18n({
      default: `{
        count, plural,
        one {There is # assignee without a grade.}
        other {There are # assignees without grades.}
      }`,
      message: 'Number of assignees without grades.',
    }, { count: ungraded + notSubmitted })

    let data = [graded]
    if (!paperOnly) {
      data.push(ungraded)
      data.push(notSubmitted)
    }

    return (
      <View style={[style.container, this.props.style]}>
        {data.map((item, index) =>
          <TouchableOpacity underlayColor='#eeeeee00' style={style.common} key={`submission_dial_highlight_${index}`}
                              testID={`assignment-details.submission-breakdown-graph-section.${ids[index]}-dial`} onPress={() => this.onPress(index) } accessibilityTraits='button'>
            <View>
              <SubmissionGraph
                label={labels[index]}
                total={totalStudents}
                current={data[index]}
                key={index}
                testID={`${ids[index]}`}
              />
            </View>
          </TouchableOpacity>
        )}

        {paperOnly &&
          <View style={style.paperOnlyContainer} accessible={true} accessibilityLabel={paperOnlyMessage}>
            <View style={style.paperOnlyContainer} >
            <Text style={style.paperOnlyContainerLabel}>{paperOnlyMessage}</Text>
            </View>
          </View>
        }

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
  paperOnlyContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
})

export function refreshSubmissionList (props: SubmissionBreakdownGraphSectionProps): void {
  props.refreshSubmissionSummary(props.courseID, props.assignmentID)
}

export function mapStateToProps (state: AppState, ownProps: SubmissionBreakdownGraphSectionInitProps): any {
  const assignment = state.entities.assignments[ownProps.assignmentID]
  let pending = 0
  let submissionTotalCount = 0
  let summary = { graded: 0, ungraded: 0, not_submitted: 0 }
  if (assignment && assignment.submissionSummary) {
    summary = assignment.submissionSummary.data
    submissionTotalCount = summary.graded + summary.ungraded + summary.not_submitted
    pending = assignment.pending || assignment.submissionSummary.pending
  } else {
    pending = true
  }

  return {
    ...summary,
    submissionTotalCount,
    pending: pending,
  }
}

const Connected = connect(mapStateToProps, { ...SubmissionActions })(SubmissionBreakdownGraphSection)
export default (Connected: any)
