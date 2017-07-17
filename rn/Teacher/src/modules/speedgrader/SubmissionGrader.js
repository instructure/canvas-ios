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
  navigator: Navigator,
}

const DRAWER_WIDTH = 375
const COMPACT_DEVICE_WIDTH = 768

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
      selectedTabIndex: -1,
    }

    props.drawerState.registerDrawer(this)
  }

  componentWillUnmount () {
    this.props.drawerState.unregisterDrawer(this)
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
    }
  }

  captureToolTip = (toolTip: ToolTip) => {
    this.toolTip = toolTip
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
          showToolTip={showToolTip}
          dismissToolTip={dismissToolTip}
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

  renderCompact (width: number, height: number) {
    return (
      <A11yGroup
        onLayout={this.onLayout}
        style={styles.speedGrader}
      >
        <ToolTip ref={this.captureToolTip} />
        <Header
          closeModal={this.props.closeModal}
          submissionProps={this.props.submissionProps}
          submissionID={this.props.submissionID}
          assignmentID={this.props.assignmentID}
          navigator={this.props.navigator}
        />
        <SubmissionPicker
          submissionProps={this.props.submissionProps}
          submissionID={this.props.submissionID}
        />
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
          closeModal={this.props.closeModal}
          submissionProps={this.props.submissionProps}
          submissionID={this.props.submissionID}
          assignmentID={this.props.assignmentID}
          navigator={this.props.navigator}
        />
        <View style={styles.splitView}>
          <A11yGroup style={styles.left}>
            <SubmissionPicker
              submissionProps={this.props.submissionProps}
              submissionID={this.props.submissionID}
            />
            <SubmissionViewer
              {...this.props}
              size={{
                width: width - DRAWER_WIDTH, height,
              }}
              drawerInset={0}
            />
          </A11yGroup>
          <A11yGroup style={styles.right}>
            {this.renderHandleContent()}
            {this.renderTab(this.state.selectedTabIndex)}
          </A11yGroup>
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
    paddingBottom: 4,
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
