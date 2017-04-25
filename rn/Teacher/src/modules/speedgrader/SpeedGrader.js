// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  ActivityIndicator,
  VirtualizedList,
  ScrollView,
  Dimensions,
} from 'react-native'
import i18n from 'format-message'
import refresh from '../../utils/refresh'
import { connect } from 'react-redux'
import SubmissionActions from '../submissions/list/actions'
import EnrollmentActions from '../enrollments/actions'
import SubmissionGrader from './SubmissionGrader'
import { getSubmissionsProps } from '../submissions/list/get-submissions-props'
import type {
  AsyncSubmissionsDataProps,
  SubmissionDataProps,
} from '../submissions/list/submission-prop-types'

type State = {
  size: { width: number, height: number },
}

const PAGE_GUTTER_HALF_WIDTH = 10.0

export class SpeedGrader extends Component<any, SpeedGraderProps, State> {
  props: SpeedGraderProps
  state: State

  static navigatorButtons = {
    rightButtons: [{
      title: i18n('Done'),
      id: 'done',
      testId: 'done_button',
    }],
  }

  constructor (props: SpeedGraderProps) {
    super(props)

    const { height, width } = Dimensions.get('window')
    this.state = { size: { width, height } }

    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
    props.navigator.setTitle({
      title: i18n({
        default: 'SpeedGrader',
        description: 'Grade student submissions',
      }),
    })
  }

  onNavigatorEvent = (event: NavigatorEvent): void => {
    if (event.type === 'NavBarButtonPress') {
      if (event.id === 'done') {
        this.props.navigator.dismissModal()
      }
    }
  }

  onLayout = (event: any) => {
    const { width, height } = event.nativeEvent.layout
    this.setState({ size: { width, height } })
  }

  dismiss = () => {
    this.props.navigator.dismissModal()
  }

  renderItem = ({ item }: { item: SubmissionItem }) =>
    <View style={[styles.page, this.state.size]}>
      <SubmissionGrader
        courseID={this.props.courseID}
        assignmentID={this.props.assignmentID}
        userID={item.submission.userID}
        submissionID={item.submission.submissionID}
        />
    </View>

  renderScrollView = () => {
    const studentIndex = Math.max(0, this.props.submissions.findIndex(sub => sub.userID === this.props.userID))
    const x = this.state.size.width * studentIndex

    return (<ScrollView
      horizontal
      pagingEnabled
      showsHorizontalScrollIndicator={false}
      contentOffset={{ x, y: 0 }}
      style={{ marginLeft: -PAGE_GUTTER_HALF_WIDTH, marginRight: -PAGE_GUTTER_HALF_WIDTH }}
    />)
  }

  render (): React.Element<*> {
    if (!this.props.refreshing && this.props.pending || !this.props.submissions) {
      return <View style={styles.loadingWrapper}><ActivityIndicator /></View>
    }

    const items: Array<SubmissionItem> = this.props.submissions
      .map(submission => ({ key: submission.userID, submission }))

    return (
      <VirtualizedList
        onLayout={this.onLayout}
        windowSize={5}
        data={items}
        renderItem={this.renderItem}
        horizontal
        renderScrollComponent={this.renderScrollView}
        />
    )
  }
}

const styles = StyleSheet.create({
  page: {
    paddingLeft: 10,
    paddingRight: 10,
    overflow: 'hidden',
  },
  speedGrader: {
    flex: 1,
  },
  loadingWrapper: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
})

export function mapStateToProps (state: AppState, ownProps: RoutingProps): AsyncSubmissionsDataProps {
  return getSubmissionsProps(state.entities, ownProps.courseID, ownProps.assignmentID)
}

export function refreshSpeedGrader (props: SpeedGraderProps): void {
  props.refreshSubmissions(props.courseID, props.assignmentID)
  props.refreshEnrollments(props.courseID)
}

export function shouldRefresh (props: SpeedGraderProps): boolean {
  return !props.submissions || props.submissions.length === 0
}

export function isRefreshing (props: SpeedGraderProps): boolean {
  return props.pending
}

const Refreshed = refresh(
  refreshSpeedGrader,
  shouldRefresh,
  isRefreshing
)(SpeedGrader)
const Connected = connect(mapStateToProps, { ...SubmissionActions, ...EnrollmentActions })(Refreshed)

export default (Connected: React.Element<*>)

type SubmissionItem = {
  key: string,
  submission: SubmissionDataProps,
}
type RoutingProps = {
  courseID: string,
  assignmentID: string,
  userID: string,
}
type SpeedGraderActionProps = {
  refreshSubmissions: Function,
  refreshEnrollments: Function,
}
type SpeedGraderProps
  = RoutingProps
  & SpeedGraderActionProps
  & AsyncSubmissionsDataProps
  & RefreshProps
  & NavProps
