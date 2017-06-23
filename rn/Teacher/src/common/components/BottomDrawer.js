// @flow

import React, { Component } from 'react'
import {
  StyleSheet,
  Dimensions,
  Animated,
  View,
  requireNativeComponent,
} from 'react-native'
import Interactable from 'react-native-interactable'
import Button from 'react-native-button'
import i18n from 'format-message'
import DrawerState from '../../modules/speedgrader/utils/drawer-state'

let { height, width } = Dimensions.get('window')

const cycleText = i18n('Open Drawer')
const snapPointStates = [
  i18n('Full screen'),
  i18n('Half screen'),
  i18n('Closed'),
]

const DrawerHandle = requireNativeComponent('DrawerHandleView')

export type Snap = 0 | 1 | 2

// just a little extra above the drawer for usability
const HANDLE_INVISIBLE_TOP_PADDING = 16
const HANDLE_VISIBLE_PADDING = 6
const HANDLE_PADDING_TOP = HANDLE_INVISIBLE_TOP_PADDING + HANDLE_VISIBLE_PADDING
const HANDLE_PADDING_BOTTOM = 52
const HANDLE_BAR_HEIGHT = 4
const HANDLE_HEIGHT = HANDLE_PADDING_TOP + HANDLE_PADDING_BOTTOM + HANDLE_BAR_HEIGHT
// space the drawer will not enter when fully open
const DRAWER_MIN_TOP_PADDING = 60 - HANDLE_INVISIBLE_TOP_PADDING

const SNAP_DEFAULT_INDEX = 0

type Props = {
  containerWidth?: number,
  containerHeight?: number,
  children?: React.Element<*>,
  renderHandleContent?: () => any,
  drawerState: DrawerState,
}

type State = {
  height: number,
  width: number,
}

export default class BottomDrawer extends Component<any, Props, State> {
  props: Props
  state: State
  _deltaY: Animated.Value
  drawer: InteractableView

  constructor (props: Props) {
    super(props)

    this.state = {
      height: props.containerHeight || height,
      width: props.containerWidth || width,
    }

    this._deltaY = props.drawerState.deltaY
  }

  shouldComponentUpdate (nextProps: Props, nextState: State) {
    if (nextProps.containerHeight === 0) return false
    return true
  }

  componentWillReceiveProps (nextProps: Props) {
    if (nextProps.containerHeight !== this.props.containerHeight || nextProps.containerWidth !== this.props.containerWidth) {
      this.setState({ height: nextProps.containerHeight, width: nextProps.containerWidth }, () => {
        if (this.drawer) {
          this.drawer.snapTo({ index: this.props.drawerState.currentSnap })
        }
      })
    }
  }

  componentWillMount () {
    this.props.drawerState.registerDrawer(this)
  }

  componentWillUnmount () {
    this.props.drawerState.unregisterDrawer(this)
  }

  open = () => {
    if (this.props.drawerState.currentSnap === SNAP_DEFAULT_INDEX) {
      this.drawer.snapTo({ index: 1 })
    }
  }

  cycle = () => {
    let index = (this.props.drawerState.currentSnap + 1) % 3
    this.drawer.snapTo({ index })
  }

  onSnap = (e: any) => {
    this.props.drawerState.didSnapTo(e.nativeEvent.index)
  }

  snapTo = (snap: Snap, animated: boolean = true) => {
    if (this.drawer) {
      this.drawer.snapTo({ index: snap, animated: animated })
    }
  }

  captureDrawer = (d: InteractableView) => {
    this.drawer = d
  }

  getSnapPoints = () => {
    // for testing...
    const minHeight = Math.max(this.state.height, 140)
    const closed = 0
    const open = minHeight * 0.5 - HANDLE_PADDING_BOTTOM
    const fullscreen = minHeight - HANDLE_HEIGHT - DRAWER_MIN_TOP_PADDING
    return [{ y: closed }, { y: open }, { y: fullscreen }]
  }

  render () {
    let width = Math.min(700, this.state.width)
    let position = (this.state.width - width) / 2

    const snap = this.getSnapPoints().map(point => point.y) // [0, 300, 600]
    const heights = [ snap[1], snap[1], snap[snap.length - 1] ] // [300, 300, 600]
    const clampedHeight = this._deltaY.interpolate({
      inputRange: snap,
      outputRange: heights.map(h => h + HANDLE_PADDING_BOTTOM),
    })
    const bottoms = [ -snap[1], 0, 0 ] // [-300, 0, 0]
    const clampedBottom = this._deltaY.interpolate({
      inputRange: snap,
      outputRange: bottoms,
    })

    return (
      <View style={[styles.drawer, { left: position, right: position }]}>
        <Interactable.View
          ref={this.captureDrawer}
          onSnap={this.onSnap}
          verticalOnly={true}
          snapPoints={this.getSnapPoints()}
          initialPosition={this.getSnapPoints()[this.props.drawerState.currentSnap]}
          animatedValueY={this._deltaY}
          style={styles.handle}
        />
        <Animated.View
          style={[styles.drawerContent, {
            height: clampedHeight,
            top: clampedBottom,
          }]}
        >
          <View style={styles.drawerBackground} />
          <DrawerHandle
            style={[{ marginTop: -HANDLE_INVISIBLE_TOP_PADDING }]}
          >
            <Button
              accessible
              accessibilityTraits={['header', 'button']}
              onPress={this.cycle} testID='bottom-drawer.cycle'
            >
              <View style={styles.handleBar} accessibilityLabel={`${cycleText} ${snapPointStates[this.props.drawerState.currentSnap]}`}/>
            </Button>
            <View style={styles.handleContent}>{
              this.props.renderHandleContent
                ? this.props.renderHandleContent()
                : undefined
            }</View>
          </DrawerHandle>
          {this.props.children}
        </Animated.View>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  drawer: {
    transform: [{ rotate: '180deg' }],
    position: 'absolute',
    bottom: 0,
    height: HANDLE_PADDING_BOTTOM,
    backgroundColor: 'white',
  },
  drawerContent: {
    transform: [{ rotate: '180deg' }],
    position: 'absolute',
    left: 0,
    right: 0,
  },
  drawerBackground: {
    backgroundColor: 'white',
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    shadowColor: 'black',
    shadowOffset: { width: 0, height: 0 },
    shadowRadius: 3,
    shadowOpacity: 0.3,
    borderTopLeftRadius: 12,
    borderTopRightRadius: 12,
  },
  handle: {
    position: 'absolute',
    left: global.style.defaultPadding,
    right: global.style.defaultPadding,
    height: HANDLE_HEIGHT,
  },
  handleBar: {
    width: 40,
    height: HANDLE_BAR_HEIGHT,
    backgroundColor: 'darkgray',
    borderRadius: 5,
    marginTop: HANDLE_PADDING_TOP,
    alignSelf: 'center',
  },
  handleContent: {
    marginTop: HANDLE_VISIBLE_PADDING,
  },
})
