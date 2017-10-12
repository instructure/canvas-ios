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
import GroupActions from '../groups/actions'
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
import Screen from '../../routing/Screen'
import Navigator from '../../routing/Navigator'
import DrawerState, { type DrawerPosition } from './utils/drawer-state'
import Tutorial from './components/Tutorial'
import i18n from 'format-message'
import Images from '../../images'
import shuffle from 'knuth-shuffle-seeded'
import A11yGroup from '../../common/components/A11yGroup'

type State = {
  size: { width: number, height: number },
  currentStudentID: string,
  filteredIDs?: Array<string>,
  drawerInset: number,
  hasScrolledToInitialSubmission: boolean,
}

const PAGE_GUTTER_HALF_WIDTH = 10.0

export class SpeedGrader extends Component<any, SpeedGraderProps, State> {
  props: SpeedGraderProps
  state: State
  _flatList: ?FlatList

  static drawerState = new DrawerState()

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
      drawerInset: SpeedGrader.drawerState.drawerHeight(position, height),
      hasScrolledToInitialSubmission: false,
    }
    SpeedGrader.drawerState.registerDrawer(this)
    this.currentPageIndex = props.studentIndex
  }

  snapTo = (position: DrawerPosition) => {
    this.setState({ drawerInset: SpeedGrader.drawerState.drawerHeight(position, this.state.size.height) })
  }

  componentWillMount () {
    this.setFilteredIDs(this.props)
  }

  componentWillReceiveProps (nextProps: SpeedGraderProps) {
    this.setFilteredIDs(nextProps)
  }

  setFilteredIDs = (props: SpeedGraderProps) => {
    if (props.submissions.length && !this.state.filteredIDs) {
      let filteredSubmissions = props.filter
        ? props.filter(props.submissions)
        : props.submissions

      this.setState({
        filteredIDs: filteredSubmissions.map(({ userID }) => userID),
      })
    }
  }

  componentWillUnmount () {
    SpeedGrader.drawerState.unregisterDrawer(this)
    SpeedGrader.drawerState.snapTo(0, false)
    this.props.refreshSubmissions(this.props.courseID, this.props.assignmentID, false)
    this.props.refreshSubmissionSummary(this.props.courseID, this.props.assignmentID)
  }

  onLayout = (event: any) => {
    const { width, height } = event.nativeEvent.layout
    if (height !== 0 && (width !== this.state.size.width || height !== this.state.size.height)) {
      this.setState({ size: { width, height } })
    }

    this.setState((prevState, props) => {
      if (this._flatList == null || prevState.hasScrolledToInitialSubmission) {
        return prevState
      }
      this._flatList.scrollToOffset({ animated: false, offset: this.state.size.width * this.props.studentIndex })
      return { ...prevState, hasScrolledToInitialSubmission: true }
    })

    this._flatList.scrollToOffset({ animated: false, offset: width * this.currentPageIndex })
  }

  _captureFlatList = (list: FlatList) => {
    this._flatList = list
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

    return <A11yGroup style={[styles.page, this.state.size]}>
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
        drawerInset={this.state.drawerInset}
        gradeSubmissionWithRubric={this.props.gradeSubmissionWithRubric}
      />
    </A11yGroup>
  }

  scrollEnded = (event: Object) => {
    const index = event.nativeEvent.contentOffset.x / this.state.size.width
    this.currentPageIndex = index
    const submission = this.filteredSubmissions()[index]
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

  filteredSubmissions (): Array<SubmissionItem> {
    return this.props.submissions
      .filter(submission => this.state.filteredIDs && this.state.filteredIDs.includes(submission.userID))
  }

  renderBody = () => {
    if (!this.props.refreshing && this.props.pending || !this.props.submissions) {
      return <View style={styles.loadingWrapper}><ActivityIndicator /></View>
    }

    const items = this.filteredSubmissions()
      .map(submission => ({ key: submission.userID, submission }))

    return (
      <FlatList
        ref={this._captureFlatList}
        keyboardShouldPersistTaps='handled'
        onLayout={this.onLayout}
        data={items}
        renderItem={this.renderItem}
        windowSize={5}
        horizontal
        pagingEnabled
        getItemLayout={this.getItemLayout}
        showsHorizontalScrollIndicator={false}
        onMomentumScrollEnd={this.scrollEnded}
        contentOffset={{ x: this.state.size.width * this.props.studentIndex }}
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
        id: 'long-press-tutorial',
        text: i18n('Tap and hold a rubric number to see its description'),
        image: Images.speedGrader.longPress,
      })
    }

    return (
      <Screen
        navBarHidden={true}
        statusBarHidden={true}
        noRotationInVerticallyCompact={true}
      >
        <View style={styles.speedGrader}>
          { !!this.state.filteredIDs && this.renderBody() }
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
  let groupAssignment = null
  if (assignmentContent && assignmentContent.data) {
    const a = assignmentContent.data
    if (a.group_category_id) {
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

  let anonymous = state.entities.assignments[ownProps.assignmentID].anonymousGradingOn

  return {
    ...props,
    submissions: anonymous ? shuffle(props.submissions.slice(), ownProps.assignmentID) : props.submissions,
    groupAssignment,
    submissionEntities: state.entities.submissions,
    assignmentSubmissionTypes: state.entities.assignments[ownProps.assignmentID].data.submission_types,
    isModeratedGrading: !!state.entities.assignments[ownProps.assignmentID].data.moderated_grading,
    hasRubric: !!state.entities.assignments[ownProps.assignmentID].data.rubric,
    hasAssignment: !!state.entities.assignments[ownProps.assignmentID].data.id,
  }
}

export function refreshSpeedGrader (props: SpeedGraderProps): void {
  props.refreshAssignment(props.courseID, props.assignmentID)
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

const Refreshed = refresh(
  refreshSpeedGrader,
  shouldRefresh,
  isRefreshing
)(SpeedGrader)
const Connected = connect(mapStateToProps, {
  ...SubmissionActions,
  ...EnrollmentActions,
  ...AssignmentActions,
  ...GroupActions,
  ...SpeedGraderActions,
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
  & { navigator: Navigator }
