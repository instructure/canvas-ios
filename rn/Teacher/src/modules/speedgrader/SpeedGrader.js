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

/* eslint-disable flowtype/require-valid-file-annotation */

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  ActivityIndicator,
  FlatList,
  Dimensions,
  DeviceInfo,
  NativeModules,
  Button,
} from 'react-native'
import refresh from '../../utils/refresh'
import { connect } from 'react-redux'
import SubmissionActions from '../submissions/list/actions'
import EnrollmentActions from '../enrollments/actions'
import AssignmentActions from '../assignments/actions'
import GroupActions from '../groups/actions'
import CourseActions from '../courses/actions'
import SubmissionGrader from './SubmissionGrader'
import SpeedGraderActions from './actions'
import { getSubmissionsProps } from '../submissions/list/get-submissions-props'
import {
  getGroupSubmissionProps,
} from '../groups/submissions/get-group-submission-props'
import type {
  AsyncSubmissionsDataProps,
  SubmissionDataProps,
} from '../submissions/list/submission-prop-types'
import { updateBadgeCounts } from '../tabbar/badge-counts'
import Screen from '../../routing/Screen'
import Navigator from '../../routing/Navigator'
import DrawerState, { type DrawerPosition } from './utils/drawer-state'
import Tutorial from './components/Tutorial'
import i18n from 'format-message'
import Images from '../../images'
import shuffle from 'knuth-shuffle-seeded'
import { Title } from '../../common/text'

const { NativeAccessibility } = NativeModules

type State = {
  size: { width: number, height: number },
  currentStudentID: ?string,
  drawerInset: number,
  hasScrolledToInitialSubmission: boolean,
  hasSetInitialDrawerPosition: boolean,
  submissions?: Array<SubmissionDataProps>,
}

const PAGE_GUTTER_HALF_WIDTH = 10.0
const REFRESH_TTL = 1000 * 60 * 15 // 15 minutes

export class SpeedGrader extends Component<SpeedGraderProps, State> {
  props: SpeedGraderProps
  state: State
  _flatList: ?FlatList
  scrollView: ?{ setNativeProps: (Object) => void }
  hasRenderedBody = false

  static drawerState = new DrawerState()
  static defaultProps = {
    onDismiss: () => {},
    drawerPosition: 0,
  }

  constructor (props: SpeedGraderProps) {
    super(props)

    const { height, width } = Dimensions.get('window')
    const position = SpeedGrader.drawerState.currentSnap
    this.state = {
      size: {
        width: width + PAGE_GUTTER_HALF_WIDTH + PAGE_GUTTER_HALF_WIDTH,
        height,
      },
      currentStudentID: props.userID,
      currentPageIndex: props.studentIndex,
      drawerInset: SpeedGrader.drawerState.drawerHeight(position, height),
      hasScrolledToInitialSubmission: false,
      hasSetInitialDrawerPosition: false,
      scrollEnabled: true,
    }
  }

  componentDidMount () {
    this.setSubmissions(this.props)
    SpeedGrader.drawerState.registerDrawer(this)
  }

  componentWillReceiveProps (nextProps: SpeedGraderProps) {
    this.setSubmissions(nextProps)
  }

  // DrawerObserver
  snapTo = (position: DrawerPosition) => {
    this.setState({ drawerInset: SpeedGrader.drawerState.drawerHeight(position, this.state.size.height) })
  }

  setSubmissions (props: SpeedGraderProps) {
    // We can only set submissions once because of filters.
    // Also don't set if we are still pending...
    if (this.state.submissions || props.pending) return

    const submissions = props.filter
      ? props.filter(props.submissions)
      : props.submissions
    let currentPageIndex = this.state.currentPageIndex
    // when enrollments came back before submissions this would get set and then
    // not set again because of the if/return statements above
    // don't set this unless we have submissions
    if (submissions.length && currentPageIndex == null || currentPageIndex < 0) {
      const index = submissions.findIndex(s => {
        return s.userID === props.userID
      })
      currentPageIndex = Math.max(0, index)
    }

    this.setState({
      submissions,
      currentPageIndex,
    })
  }

  componentWillUnmount () {
    SpeedGrader.drawerState.unregisterDrawer(this)
    SpeedGrader.drawerState.snapTo(0, false)
    this.props.refreshSubmissions(this.props.courseID, this.props.assignmentID, false)
    this.props.refreshSubmissionSummary(this.props.courseID, this.props.assignmentID)
    this.props.refreshAssignment(this.props.courseID, this.props.assignmentID)
    updateBadgeCounts()
  }

  onLayout = (event: any) => {
    let viewableAreaChanged = false
    const { width, height } = event.nativeEvent.layout
    if (height !== 0 && (width !== this.state.size.width || height !== this.state.size.height)) {
      viewableAreaChanged = true
      this.setState({ size: { width, height } })
    }

    this.setState((prevState, props) => {
      let nextState = prevState

      if (this._flatList && !prevState.hasSetInitialDrawerPosition) {
        if (this.getInitialTabIndex() >= 0) {
          SpeedGrader.drawerState.snapTo(this.getInitialTabIndex(), false)
        }
        nextState = { ...nextState, hasSetInitialDrawerPosition: true }
      }

      const scrollToCurrentPageIndex = !prevState.hasScrolledToInitialSubmission || viewableAreaChanged

      if (this._flatList && scrollToCurrentPageIndex) {
        this._flatList.scrollToOffset({ animated: false, offset: nextState.size.width * this.state.currentPageIndex })
        nextState = { ...nextState, hasScrolledToInitialSubmission: true }
      }

      return nextState
    })
  }

  _captureFlatList = (list: FlatList) => {
    this._flatList = list
  }

  renderItem = ({ item, index }: { item: SubmissionItem, index: number }) => {
    const submissionEntity = item.submission.submissionID != null
      ? this.props.submissionEntities[item.submission.submissionID]
      : null
    const selectedIndex = submissionEntity != null
      ? submissionEntity.selectedIndex
      : null
    const selectedAttachmentIndex = submissionEntity != null
      ? submissionEntity.selectedAttachmentIndex
      : null

    const isCurrentStudent = this.state.currentStudentID
      ? this.state.currentStudentID === item.submission.userID
      : index === 0

    return <View style={[styles.page, this.state.size]}>
      <SubmissionGrader
        isCurrentStudent={isCurrentStudent}
        drawerState={SpeedGrader.drawerState}
        courseID={this.props.courseID}
        assignmentID={this.props.assignmentID}
        userID={item.submission.userID}
        submissionID={item.submission.submissionID}
        closeModal={this.dismiss}
        submissionProps={item.submission}
        selectedIndex={selectedIndex}
        selectedAttachmentIndex={selectedAttachmentIndex}
        assignmentSubmissionTypes={this.props.assignmentSubmissionTypes}
        isModeratedGrading={this.props.isModeratedGrading}
        navigator={this.props.navigator}
        drawerInset={this.state.drawerInset}
        gradeSubmissionWithRubric={this.props.gradeSubmissionWithRubric}
        selectedTabIndex={this.getInitialTabIndex()}
        setScrollEnabled={(value) => {
          this.scrollView.setNativeProps({ scrollEnabled: value })
        }}
      />
    </View>
  }

  dismiss = () => {
    this.props.navigator.dismiss()
    this.props.onDismiss()
  }

  scrollEnded = (event: Object) => {
    const index = event.nativeEvent.contentOffset.x / this.state.size.width
    this.setState({ currentPageIndex: index })
    const submission = (this.state.submissions || [])[index]
    if (submission) {
      const currentStudentID = submission.userID
      if (currentStudentID !== this.state.currentStudentID) {
        this.setState({ currentStudentID })
      }
    }
  }

  getItemLayout = (data: ?any, index: number) => ({
    length: this.state.size.width,
    offset: this.state.size.width * index,
    index,
  })

  getInitialTabIndex = () => {
    if (this.props.pushNotification && this.props.pushNotification.alert.toLowerCase().startsWith(i18n('submission comment'))) {
      return 1
    }
    return -1
  }

  renderBody = () => {
    if (this.props.pending || !this.state.submissions) {
      return (
        <View
          accessible
          accessibilityLabel={i18n('In Progress')}
          style={styles.loadingWrapper}
        >
          <ActivityIndicator />
        </View>
      )
    }

    // This is rare, but if it does happen, SpeedGrader gets into a loading loop and the app basically explodes
    // jk, it loads forever and you can't do anything else unless you force close the app
    if (!this.state.submissions.length) {
      return (
        <View
          accessible
          accessibilityLabel={i18n('No Submissions to Display')}
          style={styles.loadingWrapper}
        >
          <Title style={{ margin: global.style.defaultPadding, textAlign: 'center' }}>{i18n("It seems there aren't any valid submissions to grade.")}</Title>
          <Button onPress={this.dismiss} title={i18n('Close')} />
        </View>
      )
    }

    if (!this.hasRenderedBody) {
      this.hasRenderedBody = true
      NativeAccessibility.refresh()
    }

    const items = this.state.submissions
      .map(submission => ({ key: submission.userID, submission }))

    return (
      <FlatList
        ref={this._captureFlatList}
        keyboardShouldPersistTaps='handled'
        onLayout={this.onLayout}
        data={items}
        renderItem={this.renderItem}
        windowSize={5}
        initialNumToRender={null}
        horizontal
        pagingEnabled
        getItemLayout={this.getItemLayout}
        showsHorizontalScrollIndicator={false}
        onMomentumScrollEnd={this.scrollEnded}
        initialScrollIndex={this.state.currentPageIndex}
        style={{ marginLeft: -PAGE_GUTTER_HALF_WIDTH, marginRight: -PAGE_GUTTER_HALF_WIDTH }}
        ref={(e) => { this.scrollView = e }}
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
        id: 'long-press-tutorial',
        text: i18n('Tap and hold a rubric number to see its description'),
        image: Images.speedGrader.longPress,
      })
    }

    return (
      <Screen
        navBarHidden
        statusBarHidden={!DeviceInfo.isIPhoneX_deprecated}
        noRotationInVerticallyCompact
      >
        <View style={styles.speedGrader}>
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
  const entities = state.entities
  const { courseID, assignmentID } = ownProps

  const assignmentContent = entities.assignments[assignmentID]
  const assignmentData = assignmentContent && assignmentContent.data
  const quiz = assignmentData && assignmentData.quiz_id && entities.quizzes[assignmentData.quiz_id] && entities.quizzes[assignmentData.quiz_id].data
  const courseContent = state.entities.courses[courseID]
  let anonymous = (
    assignmentContent && assignmentContent.anonymousGradingOn ||
    quiz && quiz.anonymous_submissions ||
    courseContent && courseContent.enabledFeatures.includes('anonymous_grading')
  )

  let groupAssignment = null
  if (assignmentContent && assignmentContent.data) {
    const a = assignmentContent.data
    const groupExists = a.group_category_id && courseContent.groups.refs
      .filter(ref => entities.groups[ref].group.group_category_id === a.group_category_id)
      .length > 0
    if (groupExists) {
      groupAssignment = {
        groupCategoryID: a.group_category_id,
        gradeIndividually: a.grade_group_students_individually,
      }
    }
  }

  let props
  if (groupAssignment && !groupAssignment.gradeIndividually) {
    props = getGroupSubmissionProps(entities, courseID, assignmentID)
  } else {
    props = getSubmissionsProps(entities, courseID, assignmentID)
  }

  const result = {
    ...props,
    submissions: anonymous ? shuffle(props.submissions.slice(), quiz && quiz.id || ownProps.assignmentID) : props.submissions,
    groupAssignment,
    submissionEntities: state.entities.submissions,
    assignmentSubmissionTypes: assignmentData ? assignmentData.submission_types : [],
    isModeratedGrading: !!(assignmentData && assignmentData.moderated_grading),
    hasRubric: !!(assignmentData && assignmentData.rubric),
    hasAssignment: !!(assignmentData && assignmentData.id),
  }

  return result
}

export function refreshSpeedGrader (props: SpeedGraderProps): void {
  props.refreshAssignment(props.courseID, props.assignmentID)
  props.getCourseEnabledFeatures(props.courseID)
  if (props.groupAssignment && !props.groupAssignment.gradeIndividually) {
    props.refreshGroupsForCourse(props.courseID)
    props.refreshSubmissions(props.courseID, props.assignmentID, true)
  } else {
    props.refreshSubmissions(props.courseID, props.assignmentID, false)
    props.refreshEnrollments(props.courseID)
  }
}

export function shouldRefresh (props: SpeedGraderProps): boolean {
  return !props.hasAssignment || !props.submissions || props.submissions.length === 0
}

export function isRefreshing (props: SpeedGraderProps): boolean {
  return props.pending
}

export function ttlKeyExtractor (props: SpeedGraderProps): string {
  return `${props.courseID}-${props.assignmentID}`
}

const Refreshed = refresh(
  refreshSpeedGrader,
  shouldRefresh,
  isRefreshing,
  REFRESH_TTL,
  ttlKeyExtractor,
)(SpeedGrader)
const Connected = connect(mapStateToProps, {
  ...SubmissionActions,
  ...EnrollmentActions,
  ...AssignmentActions,
  ...GroupActions,
  ...SpeedGraderActions,
  ...CourseActions,
})(Refreshed)

export default (Connected: any)

type SubmissionItem = {
  key: string,
  submission: SubmissionDataProps,
}
type RoutingProps = {
  courseID: string,
  assignmentID: string,
  userID: string,
  filter?: Function,
  studentIndex: number,
}
type SpeedGraderActionProps = {
  refreshSubmissions: Function,
  refreshSubmissionSummary: Function,
  refreshEnrollments: Function,
  refreshAssignment: Function,
  refreshGroupsForCourse: Function,
  gradeSubmissionWithRubric: Function,
}
type SpeedGraderDataProps = {
  submissionEntities: SubmissionsState,
  groupAssignment: ?{ groupCategoryID: string, gradeIndividually: boolean },
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
  & PushNotificationProps
  & { navigator: Navigator, onDismiss: Function }
