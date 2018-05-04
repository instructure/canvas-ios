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
  SegmentedControlIOS,
  StyleSheet,
  Dimensions,
} from 'react-native'
import i18n from 'format-message'
import BottomDrawer from '../../common/components/BottomDrawer'
import Header from './components/Header'
import SubmissionPicker from './components/SubmissionPicker'
import GradeTab from './GradeTab'
import FilesTab from './components/FilesTab'
import CommentsTab from './comments/CommentsTab'
import DrawerState, { type DrawerPosition } from './utils/drawer-state'
import SubmissionViewer from './SubmissionViewer'
import ToolTip from '../../common/components/ToolTip'
import A11yGroup from '../../common/components/A11yGroup'
import colors from '../../common/colors'
import SimilarityScore from './components/SimilarityScore'

let { width, height } = Dimensions.get('window')

type State = {
  width: number,
  height: number,
  selectedTabIndex: number,
  unsavedChanges: ?{ [string]: RubricAssessment },
}

type SubmissionGraderProps = {
  isCurrentStudent: boolean,
  closeModal: Function,
  courseID: string,
  assignmentID: string,
  userID: string,
  submissionID: ?string,
  submissionProps: Object,
  selectedIndex: ?number,
  selectedAttachmentIndex: number,
  drawerState: DrawerState,
  assignmentSubmissionTypes: Array<SubmissionType>,
  isModeratedGrading: boolean,
  drawerInset: number,
  navigator: Navigator,
  gradeSubmissionWithRubric: Function,
  setScrollEnabled: (boolean) => void,
}

const DRAWER_WIDTH = 375
const COMPACT_DEVICE_WIDTH = 834

export default class SubmissionGrader extends Component<SubmissionGraderProps, State> {
  state: State
  props: SubmissionGraderProps
  drawer: BottomDrawer
  toolTip: ?ToolTip
  gradeTab: GradeTab

  constructor (props: SubmissionGraderProps) {
    super(props)

    // $FlowFixMe
    this.state = {
      width: width,
      height: height,
      selectedTabIndex: props.selectedTabIndex || -1,
      unsavedChanges: null,
    }
  }

  componentDidMount () {
    this.props.drawerState.registerDrawer(this)
  }

  componentWillUnmount () {
    this.props.drawerState.unregisterDrawer(this)
  }

  saveUnsavedChanges = () => {
    this.setState({
      unsavedChanges: null,
    })
    this.props.gradeSubmissionWithRubric(
      this.props.courseID,
      this.props.assignmentID,
      this.props.userID,
      this.props.submissionID,
      this.state.unsavedChanges,
    )
  }

  componentWillReceiveProps (newProps: SubmissionGraderProps) {
    if (this.props.isCurrentStudent && !newProps.isCurrentStudent && this.state.unsavedChanges) {
      this.saveUnsavedChanges()
    }
  }

  onDragBegan = () => {
    if (this.props.drawerState.currentSnap === 0) {
      this.setState({
        selectedTabIndex: 0,
      })
    }
  }

  snapTo = (position: DrawerPosition) => {
    if (position === 0) {
      this.setState({
        selectedTabIndex: -1,
      })
    } else if (this.state.selectedTabIndex < 0) {
      this.setState({
        selectedTabIndex: 0,
      })
    }
  }

  captureToolTip = (toolTip: any) => {
    this.toolTip = toolTip
  }

  updateUnsavedChanges = (newRatings: ?{ [string]: RubricAssessment }) => {
    this.setState({ unsavedChanges: newRatings })
  }

  changeTab = (e: any) => {
    this.setState({
      selectedTabIndex: e.nativeEvent.selectedSegmentIndex,
    }, () => {
      if (this.props.drawerState.currentSnap === 0) {
        this.props.drawerState.snapTo(1)
      }
    })
  }

  onLayout = (e: any) => {
    this.setState({
      width: e.nativeEvent.layout.width,
      height: e.nativeEvent.layout.height,
    })
  }

  renderTab (tab: ?number) {
    switch (tab) {
      case 1:
        return <CommentsTab {...this.props} />
      case 2:
        return <FilesTab {...this.props} />
      default:
        const showToolTip = this.toolTip ? this.toolTip.showToolTip : undefined
        const dismissToolTip = this.toolTip ? this.toolTip.dismissToolTip : undefined
        return <GradeTab
          {...this.props}
          unsavedChanges={this.state.unsavedChanges}
          showToolTip={showToolTip}
          dismissToolTip={dismissToolTip}
          updateUnsavedChanges={this.updateUnsavedChanges}
        />
    }
  }

  filesTabLabel () {
    const submission = this.props.submissionProps.submission
    const selectedIndex = this.props.selectedIndex
    let defaultLabel = i18n('Files')
    if (!submission || submission.submission_type !== 'online_upload') return defaultLabel
    if (selectedIndex == null) {
      if (!submission.attachments) return defaultLabel
      var numberOfFiles = submission.attachments.length
    } else {
      if (!submission.submission_history[selectedIndex] ||
          !submission.submission_history[selectedIndex].attachments) {
        return defaultLabel
      }
      numberOfFiles = submission.submission_history[selectedIndex].attachments.length
    }
    return i18n('Files ({ numberOfFiles, number })', { numberOfFiles })
  }

  renderHandleContent = () => {
    return (
      <View style={styles.controlWrapper}>
        <SegmentedControlIOS
          testID='speedgrader.segment-control'
          values={[
            i18n('Grades'),
            i18n('Comments'),
            this.filesTabLabel(),
          ]}
          selectedIndex={this.state.selectedTabIndex}
          onChange={this.changeTab}
          tintColor={colors.primaryButtonColor}
        />
      </View>
    )
  }

  donePressed = () => {
    if (this.state.unsavedChanges) {
      this.saveUnsavedChanges()
    }
    this.props.closeModal()
  }

  renderCompact (width: number, height: number) {
    return (
      <A11yGroup
        onLayout={this.onLayout}
        style={styles.speedGrader}
      >
        <ToolTip ref={this.captureToolTip} />
        <Header
          closeModal={this.donePressed}
          submissionProps={this.props.submissionProps}
          submissionID={this.props.submissionID}
          assignmentID={this.props.assignmentID}
          navigator={this.props.navigator}
          courseID={this.props.courseID}
          userID={this.props.userID}
        />
        <SubmissionPicker
          submissionProps={this.props.submissionProps}
          submissionID={this.props.submissionID}
        />
        <SimilarityScore submissionID={this.props.submissionID} />
        <SubmissionViewer {...this.props} size={{ width, height }} />
        <BottomDrawer
          drawerState={this.props.drawerState}
          containerWidth={this.state.width}
          containerHeight={this.state.height}
          renderHandleContent={this.renderHandleContent}
        >
          {this.renderTab(this.state.selectedTabIndex)}
        </BottomDrawer>
      </A11yGroup>
    )
  }

  renderWide (width: number, height: number) {
    return (
      <A11yGroup
        onLayout={this.onLayout}
        style={styles.speedGrader}
      >
        <Header
          style={styles.splitViewHeader}
          closeModal={this.donePressed}
          submissionProps={this.props.submissionProps}
          submissionID={this.props.submissionID}
          assignmentID={this.props.assignmentID}
          courseID={this.props.courseID}
          navigator={this.props.navigator}
          userID={this.props.userID}
        />
        <View style={styles.splitView}>
          <View style={styles.left}>
            <SubmissionPicker
              submissionProps={this.props.submissionProps}
              submissionID={this.props.submissionID}
            />
            <SimilarityScore submissionID={this.props.submissionID} />
            <SubmissionViewer
              {...this.props}
              size={{
                height,
                width: width - DRAWER_WIDTH,
              }}
              drawerInset={0}
            />
          </View>
          <View style={styles.right}>
            {this.renderHandleContent()}
            {this.renderTab(this.state.selectedTabIndex)}
          </View>
        </View>
        <ToolTip ref={this.captureToolTip} />
      </A11yGroup>
    )
  }

  render () {
    const { width, height } = this.state
    if (width > COMPACT_DEVICE_WIDTH) {
      return this.renderWide(width, height)
    } else {
      return this.renderCompact(width, height)
    }
  }
}

const styles = StyleSheet.create({
  speedGrader: {
    flex: 1,
  },
  controlWrapper: {
    paddingHorizontal: 16,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgray',
    paddingBottom: 8,
  },
  splitViewHeader: {
    paddingBottom: 16,
    borderBottomColor: colors.seperatorColor,
    borderBottomWidth: StyleSheet.hairlineWidth,
  },
  splitView: {
    flexDirection: 'row',
    flex: 1,
  },
  right: {
    width: DRAWER_WIDTH,
    paddingTop: 16,
    borderLeftWidth: StyleSheet.hairlineWidth,
    borderLeftColor: colors.seperatorColor,
  },
  left: {
    flex: 1,
  },
})
