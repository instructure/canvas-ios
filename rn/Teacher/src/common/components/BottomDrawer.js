// @flow

import React, { Component } from 'react'
import {
  StyleSheet,
  Dimensions,
  Animated,
  View,
} from 'react-native'
import Interactable from 'react-native-interactable'
import { BlurView } from 'react-native-blur'

let { height, width } = Dimensions.get('window')

const CLOSED_PANEL_HEIGHT = 59

type Props = {
  containerWidth?: number,
  containerHeight?: number,
  children?: React.Element<*>,
}

type State = {
  height: number,
  width: number,
  currentSnap: 0 | 1 | 2,
  bottomPadding: number,
}

export default class BottomDrawer extends Component {
  props: Props
  state: State
  _deltaY: Animated.Value
  drawer: InteractableView

  constructor (props: Props) {
    super(props)

    this.state = {
      height: props.containerHeight || height,
      width: props.containerWidth || width,
      currentSnap: 2,
      bottomPadding: height * 0.8 - CLOSED_PANEL_HEIGHT,
    }

    this._deltaY = new Animated.Value(this.state.height - CLOSED_PANEL_HEIGHT)
  }

  componentWillReceiveProps (nextProps: Props) {
    if (nextProps.containerHeight !== this.props.containerHeight || nextProps.containerWidth !== this.props.containerWidth) {
      this.setState({ height: nextProps.containerHeight, width: nextProps.containerWidth }, () => {
        this.drawer.snapTo({ index: this.state.currentSnap })
      })
    }
  }

  open () {
    if (this.state.currentSnap === 2) {
      this.drawer.snapTo({ index: 1 })
    }
  }

  onSnap = (e: any) => {
    if (e.nativeEvent.index !== this.state.currentSnap) {
      this.setState({
        currentSnap: e.nativeEvent.index,
      })
    }
  }

  getSnapPoints = () => {
    return [
      { y: this.state.height * 0.2 - CLOSED_PANEL_HEIGHT },
      { y: this.state.height * 0.6 - CLOSED_PANEL_HEIGHT },
      { y: this.state.height - CLOSED_PANEL_HEIGHT }]
  }

  render () {
    let width = Math.min(700, this.state.width)
    let position = (this.state.width - width) / 2
    return (
      <Interactable.View
        ref={(e) => { this.drawer = e }}
        onSnap={this.onSnap}
        verticalOnly={true}
        snapPoints={this.getSnapPoints()}
        initialPosition={{ y: this.state.height - CLOSED_PANEL_HEIGHT }}
        animatedValueY={this._deltaY}
        style={[styles.panelContainer, { left: position, right: position }]}
        onLayout={this.onLayout}
      >
        <View style={[styles.absolute, styles.shadow]} />
        <BlurView
          style={styles.absolute}
          blurType="xlight"
          blurAmount={10}>
        <Animated.View
          style={[styles.panel, {
            height: this.state.height,
            paddingBottom: this._deltaY.interpolate({
              inputRange: [this.state.height * 0.2 - CLOSED_PANEL_HEIGHT, this.state.height - CLOSED_PANEL_HEIGHT],
              outputRange: [this.state.height * 0.2 - CLOSED_PANEL_HEIGHT, this.state.height - CLOSED_PANEL_HEIGHT],
            }),
          }]}
        >
          <View style={styles.handleWrapper}>
            <View style={styles.handle} />
          </View>
          {this.props.children}
        </Animated.View>
        </BlurView>
      </Interactable.View>
    )
  }
}

const styles = StyleSheet.create({
  panelContainer: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    maxWidth: 700,
  },
  panel: {
    paddingTop: 16,
    paddingBottom: 0,
    flex: 1,
  },
  handleWrapper: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    alignItems: 'center',
    marginVertical: 6,
  },
  handle: {
    width: 40,
    height: 4,
    backgroundColor: 'darkgray',
    borderRadius: 5,
    marginTop: 4,
    marginBottom: 8,
  },
  shadow: {
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 0 },
    shadowRadius: 3,
    shadowOpacity: 1,
    backgroundColor: '#FFFFFF55',
  },
  absolute: {
    borderRadius: 12,
    position: 'absolute',
    margin: 0,
    padding: 0,
    top: 0,
    bottom: -20,
    left: 0,
    right: 0,
  },
})
