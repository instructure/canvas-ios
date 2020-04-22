//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  ActivityIndicator,
  FlatList,
  Dimensions,
  NativeModules,
  Button,
} from 'react-native'
import SubmissionGrader from './SubmissionGrader'
import type {
  AsyncSubmissionsDataProps,
  SubmissionDataProps,
} from '../submissions/list/submission-prop-types'
import { updateBadgeCounts } from '../tabbar/badge-counts'
import Screen from '../../routing/Screen'
import Navigator from '../../routing/Navigator'
import DrawerState, { type DrawerPosition } from '../speedgrader/utils/drawer-state'
import Tutorial from '../speedgrader/components/Tutorial'
import i18n from 'format-message'
import Images from '../../images'
// import shuffle from 'knuth-shuffle-seeded'
import { Title } from '../../common/text'
import CommentInput from '../speedgrader/comments/CommentInput'
import A11yGroup from '../../common/components/A11yGroup'
import { graphql } from 'react-apollo'
import query from '../../canvas-api-v2/queries/SpeedGrader'

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
    SpeedGrader.drawerState.registerDrawer(this)
  }

  // DrawerObserver
  snapTo = (position: DrawerPosition) => {
    this.setState({ drawerInset: SpeedGrader.drawerState.drawerHeight(position, this.state.size.height) })
  }

  componentWillUnmount () {
    SpeedGrader.drawerState.unregisterDrawer(this)
    SpeedGrader.drawerState.snapTo(0, false)
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
    const isCurrentStudent = this.state.currentStudentID
      ? this.state.currentStudentID === item.user.id
      : index === 0

    let group = this.props.isGroupGradedAssignment
      ? this.props.groups.find(({ members }) => {
        return members.edges.find(({ member }) => member.user.id === item.user.id)
      })
      : null

    return <A11yGroup style={[styles.page, this.state.size]}>
      <SubmissionGrader
        isCurrentStudent={isCurrentStudent}
        drawerState={SpeedGrader.drawerState}
        courseID={this.props.courseID}
        assignmentID={this.props.assignmentID}
        userID={item.user.id}
        submissionID={item.id}
        closeModal={this.dismiss}
        submission={item}
        assignmentSubmissionTypes={this.props.assignmentSubmissionTypes}
        isModeratedGrading={this.props.isModeratedGrading}
        navigator={this.props.navigator}
        drawerInset={this.state.drawerInset}
        gradeSubmissionWithRubric={this.props.gradeSubmissionWithRubric}
        selectedTabIndex={this.getInitialTabIndex()}
        setScrollEnabled={(value) => {
          this.scrollView.setNativeProps({ scrollEnabled: value })
        }}
        group={group}
        anonymousGrading={this.props.anonymousGrading}
        assignment={this.props.assignment}
      />
    </A11yGroup>
  }

  dismiss = () => {
    this.props.navigator.dismiss()
    this.props.onDismiss()
  }

  scrollEnded = (event: Object) => {
    const index = event.nativeEvent.contentOffset.x / this.state.size.width
    if (index !== this.state.currentPageIndex) {
      CommentInput.persistentComment.text = ''
    }
    this.setState({ currentPageIndex: index })
    const submission = (this.props.submissions || [])[index]
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
    if (this.props.pending) {
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
    if (this.props.submissions.length === 0) {
      return (
        <View
          accessible
          accessibilityLabel={i18n('No Submissions to Display')}
          style={styles.loadingWrapper}
        >
          <Title style={{ margin: 16, textAlign: 'center' }}>{i18n("It seems there aren't any valid submissions to grade.")}</Title>
          <Button onPress={this.dismiss} title={i18n('Close')} />
        </View>
      )
    }

    if (!this.hasRenderedBody) {
      this.hasRenderedBody = true
      NativeAccessibility.refresh()
    }

    return (
      <FlatList
        ref={this._captureFlatList}
        keyboardShouldPersistTaps='handled'
        onLayout={this.onLayout}
        data={this.props.submissions}
        renderItem={this.renderItem}
        windowSize={5}
        initialNumToRender={null}
        horizontal
        pagingEnabled
        getItemLayout={this.getItemLayout}
        showsHorizontalScrollIndicator={false}
        onMomentumScrollEnd={this.scrollEnded}
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

function props (props) {
  if (props.data.loading) {
    return {
      pending: true,
      hasRubric: false,
    }
  }

  let assignment = props.data.assignment
  let rubric = assignment.rubric
  let submissions = assignment.submissions.edges.map(({ submission }) => submission)
  let course = assignment.course
  let groups = course.groups.edges.map(({ group }) => group)
  let quiz = assignment.quiz
  return {
    pending: false,
    hasRubric: rubric != null,
    assignment,
    submissions,
    isGroupGradedAssignment: (
      assignment.groupSet?.id != null &&
      !assignment.gradeGroupStudentsIndividually
    ),
    groups,
    anonymousGrading: quiz?.anonymousSubmissions ?? assignment.anonymizeStudents ?? false,
  }
}

export default graphql(query, {
  options: ({ assignmentID, filter }) => {
    return {
      variables: {
        assignmentID,
        ...filter,
      },
    }
  },
  fetchPolicy: 'cache-and-network',
  props,
})(SpeedGrader)

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
