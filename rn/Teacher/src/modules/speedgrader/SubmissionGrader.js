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
import GradeTab from './GradeTab'

let { width, height } = Dimensions.get('window')

type State = {
  width: number,
  height: number,
  selectedIndex: number,
}

type SubmissionGraderProps = {
  courseID: string,
  assignmnetID: string,
  userID: string,
  submissionID: ?string,
}

export default class SubmissionGrader extends Component<any, SubmissionGraderProps, State> {
  state: State
  props: SubmissionGraderProps
  drawer: BottomDrawer

  constructor (props: SubmissionGraderProps) {
    super(props)

    this.state = {
      width: width,
      height: height,
      selectedIndex: 0,
    }
  }

  changeTab = (e: any) => {
    this.drawer.open()
    this.setState({
      selectedIndex: e.nativeEvent.selectedSegmentIndex,
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
        return <View></View>
      case 2:
        return <View></View>
    }
  }

  render () {
    return (
      <View onLayout={this.onLayout} style={styles.speedGrader}>
        <BottomDrawer ref={e => { this.drawer = e }} containerWidth={this.state.width} containerHeight={this.state.height}>
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
                i18n({
                  default: 'Files',
                  description: 'The title of the button to switch to the files submitted for a submission',
                }),
              ]}
              selectedIndex={this.state.selectedIndex}
              onChange={this.changeTab}
            />
          </View>
          {this.renderTab(this.state.selectedIndex)}
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
