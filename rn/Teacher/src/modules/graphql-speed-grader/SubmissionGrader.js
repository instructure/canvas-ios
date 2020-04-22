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

// @flow
import React, { Component } from 'react'
import {
  View,
  SegmentedControlIOS,
  Dimensions,
} from 'react-native'
import i18n from 'format-message'
import BottomDrawer from '../../common/components/BottomDrawer'
import Header from './components/Header'
import SubmissionPicker from './components/SubmissionPicker'
// import GradeTab from './GradeTab'
// import FilesTab from './components/FilesTab'
// import CommentsTab from './comments/CommentsTab'
import DrawerState, { type DrawerPosition } from '../speedgrader/utils/drawer-state'
// import SubmissionViewer from './SubmissionViewer'
import ToolTip from '../../common/components/ToolTip'
import A11yGroup from '../../common/components/A11yGroup'
import { colors, createStyleSheet } from '../../common/stylesheet'
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
      selectedIndex: props.submission.submissionHistory.edges.length - 1,
      selectedAttachmentIndex: 0,
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

  selectSubmissionFromHistory = (index) => {
    this.setState({
      selectedIndex: index,
      selectedAttachmentIndex: 0,
    })
  }

  selectFile = (index) => {
    this.setState({ selectedAttachmentIndex: index })
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
        return null
        // return (
        //   <CommentsTab
        //     {...this.props}
        //     selectedIndex={this.state.selectedIndex}
        //     selectedAttachmentIndex={this.state.selectedAttachmentIndex}
        //     selectFile={this.selectFile}
        //     selectSubmissionFromHistory={this.selectSubmissionFromHistory}
        //   />
        // )
      case 2:
        return null
        // return (
        // <FilesTab
        //   {...this.props}
        //   selectedIndex={this.state.selectedIndex}
        //   selectedAttachmentIndex={this.state.selectedAttachmentIndex}
        //   selectFile={this.selectFile}
        //   isWide={this.isWide()}
        // />
        // )
      default:
        return null
        // const showToolTip = this.toolTip ? this.toolTip.showToolTip : undefined
        // const dismissToolTip = this.toolTip ? this.toolTip.dismissToolTip : undefined
        // return <GradeTab
        //   {...this.props}
        //   unsavedChanges={this.state.unsavedChanges}
        //   showToolTip={showToolTip}
        //   dismissToolTip={dismissToolTip}
        //   updateUnsavedChanges={this.updateUnsavedChanges}
        // />
    }
  }

  filesTabLabel () {
    const submission = this.props.submission
    const selectedIndex = this.state.selectedIndex
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
          tintColor={colors.buttonPrimaryBackground}
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

  isWide = () => this.state.width > COMPACT_DEVICE_WIDTH

  renderCompact (width: number, height: number) {
    return (
      <A11yGroup
        onLayout={this.onLayout}
        style={styles.speedGrader}
      >
        <ToolTip ref={this.captureToolTip} />
        <Header
          closeModal={this.donePressed}
          submission={this.props.submission}
          submissionID={this.props.submissionID}
          assignmentID={this.props.assignmentID}
          navigator={this.props.navigator}
          courseID={this.props.courseID}
          userID={this.props.userID}
          group={this.props.group}
          anonymousGrading={this.props.anonymousGrading}
        />
        <SubmissionPicker
          submission={this.props.submission}
          submissionID={this.props.submissionID}
          selectedIndex={this.state.selectedIndex}
          selectSubmissionFromHistory={this.selectSubmissionFromHistory}
        />
        <SimilarityScore
          submission={this.props.submission}
          selectedIndex={this.state.selectedIndex}
          selectedAttachmentIndex={this.state.selectedAttachmentIndex}
        />
        {/* <SubmissionViewer
          {...this.props}
          selectedIndex={this.state.selectedIndex}
          selectedAttachmentIndex={this.state.selectedAttachmentIndex}
          size={{ width, height }}
        />
        <BottomDrawer
          drawerState={this.props.drawerState}
          containerWidth={this.state.width}
          containerHeight={this.state.height}
          renderHandleContent={this.renderHandleContent}
        >
          {this.renderTab(this.state.selectedTabIndex)}
        </BottomDrawer> */}
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
          closeModal={this.donePressed}
          submission={this.props.submission}
          submissionID={this.props.submissionID}
          assignmentID={this.props.assignmentID}
          navigator={this.props.navigator}
          courseID={this.props.courseID}
          userID={this.props.userID}
          group={this.props.group}
          anonymousGrading={this.props.anonymousGrading}
        />
        <View style={styles.splitView}>
          <View style={styles.left}>
            <SubmissionPicker
              submission={this.props.submission}
              submissionID={this.props.submissionID}
              selectedIndex={this.state.selectedIndex}
              selectSubmissionFromHistory={this.selectSubmissionFromHistory}
            />
            <SimilarityScore
              submission={this.props.submission}
              selectedIndex={this.state.selectedIndex}
              selectedAttachmentIndex={this.state.selectedAttachmentIndex}
            />
            {/* <SubmissionViewer
              {...this.props}
              size={{
                height,
                width: width - DRAWER_WIDTH,
              }}
              drawerInset={0}
            /> */}
          </View>
          {/* <View style={styles.right}>
            {this.renderHandleContent()}
            {this.renderTab(this.state.selectedTabIndex)}
          </View> */}
        </View>
        {/* <ToolTip ref={this.captureToolTip} /> */}
      </A11yGroup>
    )
  }

  render () {
    const { width, height } = this.state
    if (this.isWide()) {
      return this.renderWide(width, height)
    } else {
      return this.renderCompact(width, height)
    }
  }
}

const styles = createStyleSheet((colors, vars) => ({
  speedGrader: {
    flex: 1,
  },
  controlWrapper: {
    paddingHorizontal: 16,
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
    paddingBottom: 8,
  },
  splitViewHeader: {
    paddingBottom: 16,
    borderBottomColor: colors.borderMedium,
    borderBottomWidth: vars.hairlineWidth,
  },
  splitView: {
    flexDirection: 'row',
    flex: 1,
  },
  right: {
    width: DRAWER_WIDTH,
    paddingTop: 16,
    borderLeftWidth: vars.hairlineWidth,
    borderLeftColor: colors.borderMedium,
  },
  left: {
    flex: 1,
  },
}))
