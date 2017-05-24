// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  Dimensions,
  Animated,
  Easing,
} from 'react-native'
import DrawerState from '../utils/drawer-state'

const DEVICE_WIDTH = Dimensions.get('window').width

type CommentStatusState = {
  width: number,
}

type CommentStatusProps = {
  isDone: boolean,
  animationComplete: Function,
  drawerState: DrawerState,
  userID: string,
}

export default class CommentStatus extends Component {
  props: CommentStatusProps
  state: CommentStatusState
  progress: Animated.Value

  constructor (props: CommentStatusProps) {
    super(props)

    this.state = { width: DEVICE_WIDTH }

    this.progress = this.props.drawerState.commentProgress[this.props.userID] || new Animated.Value(0)
    this.props.drawerState.registerCommentProgress(this.props.userID, this.progress)
  }

  componentDidMount () {
    let duration = 60000 * (1 - this.progress._value)
    Animated.timing(
      this.progress,
      {
        toValue: 0.8,
        duration,
        easing: Easing.linear,
      },
    ).start()
  }

  componentWillUnmount () {
    this.props.drawerState.unregisterCommentProgress(this.props.userID)
  }

  componentWillReceiveProps (nextProps: CommentStatusProps) {
    if (nextProps.isDone) {
      this.progress.stopAnimation()
      Animated.timing(
        this.progress,
        {
          toValue: 1,
          duration: 300,
        }
      ).start(nextProps.animationComplete)
    }
  }

  onLayout = (e: any) => {
    this.setState({
      width: e.nativeEvent.layout.width,
    })
  }

  render () {
    return (
      <View style={styles.statusBar} onLayout={this.onLayout}>
        <Animated.View
          style={[
            styles.progress,
            {
              width: this.progress.interpolate({
                inputRange: [0, 1],
                outputRange: [0, this.state.width],
              }),
            },
          ]}
        />
      </View>
    )
  }
}

const styles = StyleSheet.create({
  statusBar: {
    position: 'absolute',
    bottom: 50,
    left: 0,
    right: 0,
    height: 1,
    flexDirection: 'row',
  },
  progress: {
    backgroundColor: '#008EE2',
  },
})
