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

let { width, height } = Dimensions.get('window')

type State = {
  width: number,
  height: number,
  selectedTabIndex: number,
}

type SubmissionGraderProps = {
  closeModal: Function,
  courseID: string,
  assignmnetID: string,
  userID: string,
  submissionID: ?string,
  submissionProps: Object,
  selectedIndex: ?number,
  selectedAttachmentIndex: ?number,
  drawerState: DrawerState,
}

export default class SubmissionGrader extends Component<any, SubmissionGraderProps, State> {
  state: State
  props: SubmissionGraderProps
  drawer: typeof BottomDrawer

  constructor (props: SubmissionGraderProps) {
    super(props)

    this.state = {
      width: width,
      height: height,
      selectedTabIndex: 0,
    }
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

  renderTab (tab: ?number): ?React.Element<*> {
    switch (tab) {
      case 0:
        return <GradeTab {...this.props} />
      case 1:
        return <CommentsTab {...this.props} />
      case 2:
        return <FilesTab {...this.props} />
    }
  }

  filesTabLabel () {
    const submission = this.props.submissionProps.submission
    const selectedIndex = this.props.selectedIndex
    let defaultLabel = i18n({
      default: 'Files',
      description: 'The title of the button to switch to the files submitted for a submission',
    })
    if (!submission || !submission.attachments) return defaultLabel
    let numberOfFiles = submission.attachments.length
    if (selectedIndex != null) {
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
            i18n({
              default: 'Grades',
              description: 'The title of the button to switch to grading a submission',
            }),
            i18n({
              default: 'Comments',
              description: 'The title of the button to switch to comments on a submission',
            }),
            this.filesTabLabel(),
          ]}
          selectedIndex={this.state.selectedTabIndex}
          onChange={this.changeTab}
        />
      </View>
    )
  }

  render () {
    return (
      <View onLayout={this.onLayout} style={styles.speedGrader}>
        <Header closeModal={this.props.closeModal} submissionProps={this.props.submissionProps} submissionID={this.props.submissionID} />
        <SubmissionViewer {...this.props} />
        <BottomDrawer
          drawerState={this.props.drawerState}
          containerWidth={this.state.width}
          containerHeight={this.state.height}
          renderHandleContent={this.renderHandleContent}
        >
          {this.renderTab(this.state.selectedTabIndex)}
        </BottomDrawer>
      </View>
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
