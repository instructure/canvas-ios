// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  SegmentedControlIOS,
  Dimensions,
} from 'react-native'
import i18n from 'format-message'
import BottomDrawer from '../../common/components/BottomDrawer'

let { width, height } = Dimensions.get('window')

type Props = {
  navigator: ReactNavigator,
}

type State = {
  width: number,
  height: number,
  selectedIndex: ?number,
}

export default class Speedgrader extends Component {
  props: Props
  state: State
  drawer: BottomDrawer

  static navigatorButtons = {
    rightButtons: [{
      title: i18n('Done'),
      id: 'done',
      testId: 'done_button',
    }],
  }

  constructor (props: Props) {
    super(props)

    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
    props.navigator.setTitle({
      title: i18n({
        default: 'Speedgrader',
        description: 'Grade student submissions',
      }),
    })

    this.state = {
      width: width,
      height: height,
      selectedIndex: null,
    }
  }

  onNavigatorEvent = (event: NavigatorEvent): void => {
    if (event.type === 'NavBarButtonPress') {
      if (event.id === 'done') {
        this.props.navigator.dismissModal()
      }
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

  renderTab (tab: ?number): React.Element<*> {
    switch (tab) {
      case 0:
        return <View></View>
      case 1:
        return <View></View>
      case 2:
        return <View></View>
      default:
        return <View></View>
    }
  }

  render (): React.Element<*> {
    return (
      <View onLayout={this.onLayout} style={styles.speedGrader}>
        <BottomDrawer ref={e => { this.drawer = e }} containerWidth={this.state.width} containerHeight={this.state.height}>
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
})
