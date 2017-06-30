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
import GradeTab from './GradeTab'
import FilesTab from './components/FilesTab'
import CommentsTab from './comments/CommentsTab'
import DrawerState from './utils/drawer-state'
import SubmissionViewer from './SubmissionViewer'
import ToolTip from '../../common/components/ToolTip'
import A11yGroup from '../../common/components/A11yGroup'

let { width, height } = Dimensions.get('window')

type State = {
  width: number,
  height: number,
  selectedTabIndex: number,
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
}

export default class SubmissionGrader extends Component<any, SubmissionGraderProps, State> {
  state: State
  props: SubmissionGraderProps
  drawer: BottomDrawer
  toolTip: ?ToolTip

  constructor (props: SubmissionGraderProps) {
    super(props)

    this.state = {
      width: width,
      height: height,
      selectedTabIndex: 0,
    }
  }

  captureToolTip = (toolTip: ToolTip) => {
    this.toolTip = toolTip
  }

  changeTab = (e: any) => {
    this.setState({
      selectedTabIndex: e.nativeEvent.selectedSegmentIndex,
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
      case 0:
        const showToolTip = this.toolTip ? this.toolTip.showToolTip : undefined
        const dismissToolTip = this.toolTip ? this.toolTip.dismissToolTip : undefined
        return <GradeTab {...this.props} showToolTip={showToolTip} dismissToolTip={dismissToolTip} />
      case 1:
        return <CommentsTab {...this.props} />
      case 2:
        return <FilesTab {...this.props} />
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
      if (!submission.submission_history[selectedIndex].attachments) return defaultLabel
      numberOfFiles = submission.submission_history[selectedIndex].attachments.length
    }
    return i18n('Files ({numberOfFiles})', { numberOfFiles })
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
        />
      </View>
    )
  }

  render () {
    const { width, height } = this.state
    return (
      <A11yGroup
        onLayout={this.onLayout}
        style={styles.speedGrader}
      >
        <ToolTip ref={this.captureToolTip} />
        <Header closeModal={this.props.closeModal} submissionProps={this.props.submissionProps} submissionID={this.props.submissionID} assignmentID={this.props.assignmentID}/>
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
})
