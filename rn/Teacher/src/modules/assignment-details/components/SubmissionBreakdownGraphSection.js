/**
 * @flow
 */

import React, { Component } from 'react'
import SubmissionGraph from '../../submissions/SubmissionGraph'
import { connect } from 'react-redux'
import SubmissionActions from '../../submissions/list/actions'
import { Text, SubTitle } from '../../../common/text'
import colors from '../../../common/colors'

import {
  View,
  StyleSheet,
  TouchableOpacity,
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
  pending: boolean,
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

  renderNoSubmissions () {
    let noSubmissionsMessage = i18n('Tap to view submissions list.')
    return (
        <TouchableOpacity underlayColor='#eeeeee00' style={style.common}
                          key={`submission_dial_highlight_no_submissions`}
                          testID={`assignment-details.submission-breakdown-graph-section.no-submissions`}
                          onPress={() => this.props.onPress('') } accessible={false}>
          <Text accessible={false}>{noSubmissionsMessage}</Text>
        </TouchableOpacity>
    )
  }

  render () {
    let { graded, ungraded } = this.props
    let notSubmitted = this.props.not_submitted
    let totalStudents = this.props.submissionTotalCount
    let submissionTypes = this.props.submissionTypes || []

    let gradedLabel = i18n('Graded')
    let ungradedLabel = i18n(`{
      count, plural,
        one {Needs Grading}
      other {Need Grading}
    }`, { count: ungraded })
    let notSubmittedLabel = i18n('Not Submitted')

    let labels = [gradedLabel, ungradedLabel, notSubmittedLabel]
    let ids = ['graded', 'ungraded', 'not-submitted']

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
          <TouchableOpacity underlayColor='#eeeeee00' style={!paperOnly && style.common} key={`submission_dial_highlight_${index}`}
                              testID={`assignment-details.submission-breakdown-graph-section.${ids[index]}-dial`} onPress={() => this.onPress(index) } accessibilityTraits='button'>
            <View>
              <SubmissionGraph
                label={labels[index]}
                total={totalStudents}
                current={data[index] || 0}
                key={index}
                testID={`${ids[index]}`}
                pending={this.props.pending}
              />
            </View>
          </TouchableOpacity>
        )}

        {paperOnly &&
          <View style={style.paperOnlyContainer} accessible={true} accessibilityLabel={paperOnlyMessage}>
            <SubTitle style={{ color: colors.darkText }}>{paperOnlyMessage}</SubTitle>
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
    justifyContent: 'flex-start',
    alignItems: 'center',
    maxWidth: 400,
    paddingLeft: global.style.defaultPadding / 2,
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
    marginLeft: 32,
  },
})

export function refreshSubmissionList (props: SubmissionBreakdownGraphSectionProps): void {
  props.refreshSubmissionSummary(props.courseID, props.assignmentID)
}

export function mapStateToProps (state: AppState, ownProps: SubmissionBreakdownGraphSectionInitProps): any {
  const assignment = state.entities.assignments[ownProps.assignmentID]
  let pending = false
  let submissionTotalCount = 0
  let summary = { graded: 0, ungraded: 0, not_submitted: 0 }
  if (assignment && assignment.submissionSummary) {
    summary = assignment.submissionSummary.data
    submissionTotalCount = summary.graded + summary.ungraded + summary.not_submitted
    pending = Boolean(assignment.pending || assignment.submissionSummary.pending)
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
