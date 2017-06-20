// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  ActivityIndicator,
  FlatList,
  Dimensions,
} from 'react-native'
import refresh from '../../utils/refresh'
import { connect } from 'react-redux'
import SubmissionActions from '../submissions/list/actions'
import EnrollmentActions from '../enrollments/actions'
import AssignmentActions from '../assignments/actions'
import SubmissionGrader from './SubmissionGrader'
import { getSubmissionsProps } from '../submissions/list/get-submissions-props'
import type {
  AsyncSubmissionsDataProps,
  SubmissionDataProps,
} from '../submissions/list/submission-prop-types'
import Screen from '../../routing/Screen'
import Navigator from '../../routing/Navigator'
import DrawerState from './utils/drawer-state'
import { type SelectedSubmissionFilter } from '../submissions/SubmissionsHeader'
import Tutorial from './components/Tutorial'
import i18n from 'format-message'
import Images from '../../images'
import shuffle from 'knuth-shuffle-seeded'

type State = {
  size: { width: number, height: number },
  currentStudentID: string,
}

const PAGE_GUTTER_HALF_WIDTH = 10.0

export class SpeedGrader extends Component<any, SpeedGraderProps, State> {
  props: SpeedGraderProps
  state: State

  static drawerState = new DrawerState()

  constructor (props: SpeedGraderProps) {
    super(props)

    const { height, width } = Dimensions.get('window')
    this.state = {
      size: { width, height },
      currentStudentID: props.userID,
    }
  }

  componentWillUnmount () {
    SpeedGrader.drawerState.snapTo(0, false)
  }

  onLayout = (event: any) => {
    const { width, height } = event.nativeEvent.layout
    if (height !== 0 && width !== this.state.width && height !== this.state.height) {
      this.setState({ size: { width, height } })
      // TODO: scroll to current student
    }
  }

  dismiss = () => {
    this.props.navigator.dismiss()
  }

  renderItem = ({ item }: { item: SubmissionItem }) => {
    const submissionEntity = item.submission.submissionID != null
      ? this.props.submissionEntities[item.submission.submissionID]
      : null
    const selectedIndex = submissionEntity != null
      ? submissionEntity.selectedIndex
      : null
    const selectedAttachmentIndex = submissionEntity != null
      ? submissionEntity.selectedAttachmentIndex
      : null
    return <View style={[styles.page, this.state.size]}>
      <SubmissionGrader
        isCurrentStudent={this.state.currentStudentID === item.submission.userID}
        drawerState={SpeedGrader.drawerState}
        courseID={this.props.courseID}
        assignmentID={this.props.assignmentID}
        userID={item.submission.userID}
        submissionID={item.submission.submissionID}
        closeModal={this.props.navigator.dismiss}
        submissionProps={item.submission}
        selectedIndex={selectedIndex}
        selectedAttachmentIndex={selectedAttachmentIndex}
        assignmentSubmissionTypes={this.props.assignmentSubmissionTypes}
        isModeratedGrading={this.props.isModeratedGrading}
        navigator={this.props.navigator}
      />
    </View>
  }

  scrollEnded = (event: Object) => {
    const index = event.nativeEvent.contentOffset.x / this.state.size.width
    const submission = this.props.submissions[index]
    if (submission) {
      const currentStudentID = submission.userID
      if (currentStudentID !== this.state.currentStudentID) {
        this.setState({ currentStudentID })
      }
    }
  }

  renderBody = () => {
    if (!this.props.refreshing && this.props.pending || !this.props.submissions) {
      return <View style={styles.loadingWrapper}><ActivityIndicator /></View>
    }

    const items: Array<SubmissionItem> = this.props.submissions
      .map(submission => ({ key: submission.userID, submission }))
    const studentIndex = Math.max(0, this.props.submissions.findIndex(sub => sub.userID === this.state.currentStudentID))
    const x = this.state.size.width * studentIndex

    return (
      <FlatList
        keyboardShouldPersistTaps='handled'
        onLayout={this.onLayout}
        data={items}
        renderItem={this.renderItem}
        windowSize={5}
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
        contentOffset={{ x, y: 0 }}
        onMomentumScrollEnd={this.scrollEnded}
        style={{ marginLeft: -PAGE_GUTTER_HALF_WIDTH, marginRight: -PAGE_GUTTER_HALF_WIDTH }}
      />
    )
  }

  render () {
    let tutorials = [{
      id: 'swipe-tutorial',
      text: i18n('Swipe left or right to view other student submissions'),
      image: Images.speedGrader.swipe,
    }]

    if (this.props.hasRubric) {
      tutorials.push({
        id: 'long-press',
        text: i18n('Tap and hold a rubric number to see its description'),
        image: Images.speedGrader.longPress,
      })
    }

    return (
      <Screen
        navBarHidden={true}
        statusBarHidden={true}
      >
        <View>
          { this.renderBody() }
          <Tutorial
            tutorials={tutorials}
          />
        </View>
      </Screen>
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

export function mapStateToProps (state: AppState, ownProps: RoutingProps): SpeedGraderDataProps {
  const unfilteredProps = getSubmissionsProps(state.entities, ownProps.courseID, ownProps.assignmentID)

  const { selectedFilter } = ownProps

  const submissions = selectedFilter && selectedFilter.filter.filterFunc
    ? selectedFilter.filter.filterFunc(unfilteredProps.submissions, selectedFilter.metadata)
    : unfilteredProps.submissions

  let anonymous = state.entities.assignments[ownProps.assignmentID].anonymousGradingOn

  const props = {
    ...unfilteredProps,
    submissions: anonymous ? shuffle(submissions.slice(), ownProps.assignmentID) : submissions,
  }

  return {
    ...props,
    submissionEntities: state.entities.submissions,
    assignmentSubmissionTypes: state.entities.assignments[ownProps.assignmentID].data.submission_types,
    isModeratedGrading: !!state.entities.assignments[ownProps.assignmentID].data.moderated_grading,
    hasRubric: !!state.entities.assignments[ownProps.assignmentID].data.rubric,
    hasAssignment: !!state.entities.assignments[ownProps.assignmentID].data.id,
  }
}

export function refreshSpeedGrader (props: SpeedGraderProps): void {
  props.refreshSubmissions(props.courseID, props.assignmentID)
  props.refreshEnrollments(props.courseID)
  props.refreshAssignment(props.courseID, props.assignmentID)
}

export function shouldRefresh (props: SpeedGraderProps): boolean {
  return !props.hasAssignment || !props.submissions || props.submissions.length === 0
}

export function isRefreshing (props: SpeedGraderProps): boolean {
  return props.pending
}

const Refreshed = refresh(
  refreshSpeedGrader,
  shouldRefresh,
  isRefreshing
)(SpeedGrader)
const Connected = connect(mapStateToProps, { ...SubmissionActions, ...EnrollmentActions, ...AssignmentActions })(Refreshed)

export default (Connected: any)

type SubmissionItem = {
  key: string,
  submission: SubmissionDataProps,
}
type RoutingProps = {
  courseID: string,
  assignmentID: string,
  userID: string,
  selectedFilter?: SelectedSubmissionFilter,
}
type SpeedGraderActionProps = {
  refreshSubmissions: Function,
  refreshEnrollments: Function,
  refreshAssignment: Function,
}
type SpeedGraderDataProps = {
  submissionEntities: SubmissionsState,
  assignmentSubmissionTypes: Array<SubmissionType>,
  isModeratedGrading: boolean,
  hasRubric: boolean,
  hasAssignment: boolean,
} & AsyncSubmissionsDataProps

type SpeedGraderProps
  = RoutingProps
  & SpeedGraderActionProps
  & SpeedGraderDataProps
  & RefreshProps
  & { navigator: Navigator }
