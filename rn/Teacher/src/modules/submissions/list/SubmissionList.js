// @flow

import React, { Component } from 'react'
import { View, ListView, ScrollView } from 'react-native'
import { connect } from 'react-redux'
import type { SubmissionListProps } from './submission-prop-types'
import { mapStateToProps } from './map-state-to-props'
import i18n from 'format-message'
import SubmissionRow from './SubmissionRow'
import SubmissionActions from './actions'
import refresh from '../../../utils/refresh'

type State = {
  dataSource: ListView.DataSource,
}

type Props = SubmissionListProps & NavProps

export class SubmissionList extends Component<any, Props, State> {
  state: State

  constructor (props: Props) {
    super(props)

    props.navigator.setTitle({
      title: i18n({
        default: 'Submissions',
        description: 'Title for the list of submissions for an assignment',
      }),
    })

    if (props.course.color) {
      const color: string = props.course.color
      props.navigator.setStyle({
        navBarBackgroundColor: color,
      })
    }
  }

  render () {
    const children = this.props.submissions.map((submission) => (
      <SubmissionRow key={submission.userID} {...submission} />
    ))
    return (
      <ScrollView>
        <View>
          {children}
        </View>
      </ScrollView>
    )
  }
}

const Refreshed = refresh(
  props => props.refreshSubmissions(props.courseID, props.assignmentID),
  props => true
)(SubmissionList)
const Connected = connect(mapStateToProps, SubmissionActions)(Refreshed)
export default (Connected: Component<any, SubmissionListProps, any>)
