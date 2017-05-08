// @flow

import React, { Component } from 'react'
import {
  StyleSheet,
  Dimensions,
  Animated,
  View,
  Keyboard,
} from 'react-native'
import { connect } from 'react-redux'
import Interactable from 'react-native-interactable'

let { height, width } = Dimensions.get('window')

const CLOSED_PANEL_HEIGHT = 70
const BOTTOM_FLUFF = 1024

type Props = SnapState & {
  containerWidth?: number,
  containerHeight?: number,
  children?: React.Element<*>,
  setDrawerSnap: ((snap: Snap) => void),
}

type State = {
  height: number,
  width: number,
  bottomPadding: number,
}

export class BottomDrawer extends Component<any, Props, State> {
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
        this.drawer.snapTo({ index: this.props.currentSnap })
      })
    }
  }

  componentDidUpdate (prevProps: Props) {
    if (prevProps.currentSnap !== this.props.currentSnap) {
      this.drawer.snapTo({ index: this.props.currentSnap })
    }
  }

  open () {
    if (this.state.currentSnap === 2) {
      this.drawer.snapTo({ index: 1 })
    }
  }

  onSnap = (e: any) => {
    if (e.nativeEvent.index !== this.props.currentSnap) {
      this.props.setDrawerSnap(e.nativeEvent.index)
    }
  }

  getSnapPoints = () => {
    const fullScreen = { y: 44 }
    // open and closed must be larger than fullscreen
    // this only occurs when the view containing the
    // drawer is smaller than 44 + CLOSED_PANEL_HEIGHT
    // which happens in the unit tests
    const open = { y: Math.max(fullScreen.y + 1, this.state.height * 0.6 - CLOSED_PANEL_HEIGHT) }
    const closed = { y: Math.max(fullScreen.y + 2, this.state.height - CLOSED_PANEL_HEIGHT) }

    if (Keyboard.isVisible) {
      return [fullScreen, closed]
    } else {
      return [fullScreen, open, closed]
    }
  }

  render () {
    let width = Math.min(700, this.state.width)
    let position = (this.state.width - width) / 2

    const snap = this.getSnapPoints().map(point => point.y)
    const clamped = [...snap.slice(0, snap.length - 1), snap[1]].map(y => y + BOTTOM_FLUFF)
    const clamp = this._deltaY.interpolate({
      inputRange: snap,
      outputRange: clamped,
    })
    return (
      <Interactable.View
        ref={(e) => { this.drawer = e }}
        onSnap={this.onSnap}
        verticalOnly={true}
        snapPoints={this.getSnapPoints()}
        initialPosition={this.getSnapPoints()[this.props.currentSnap]}
        animatedValueY={this._deltaY}
        style={[styles.panelContainer, { left: position, right: position }]}
        onLayout={this.onLayout}
      >
        <View style={styles.drawerBackground} />
        <Animated.View
          style={[styles.panel, {
            height: this.state.height,
            paddingBottom: clamp,
          }]}
        >
          <View style={styles.handleWrapper}>
            <View style={styles.handle} />
          </View>
          {this.props.children}
        </Animated.View>
      </Interactable.View>
    )
  }
}

const DRAWER_SNAP_ACTION = 'com.teacher.drawer.set-snap'
const DRAWER_OPEN_ACTION = 'com.teacher.drawer.open'
type DrawerAction
  = { type: 'com.teacher.drawer.open' }
  | { type: 'com.teacher.drawer.set-snap', snap: Snap }

export const createSnapAction = (snap: Snap): DrawerAction => ({ type: DRAWER_SNAP_ACTION, snap: snap })

export function drawer (state: SnapState = { currentSnap: 2 }, action: DrawerAction): SnapState {
  switch (action.type) {
    case DRAWER_OPEN_ACTION:
      if (state.currentSnap === 2) {
        return { ...state, currentSnap: 1 }
      }
      break
    case DRAWER_SNAP_ACTION:
      return { ...state, currentSnap: action.snap }
  }
  return state
}

export const DrawerActions: any = {
  resetDrawer: () => createSnapAction(2),
  setDrawerSnap: createSnapAction,
  openDrawer: () => ({ type: DRAWER_OPEN_ACTION }),
}

export function mapStateToProps (state: AppState): SnapState {
  return state.drawer
}

const Connected = connect(mapStateToProps, DrawerActions)(BottomDrawer)
export default (Connected: any)

const styles = StyleSheet.create({
  panelContainer: {
    position: 'absolute',
    top: 0,
    bottom: -BOTTOM_FLUFF,
    left: 0,
    right: 0,
    maxWidth: 700,
  },
  panel: {
    paddingTop: 6,
    paddingBottom: 0,
    flex: 1,
  },
  handleWrapper: {
    position: 'absolute',
    top: 18,
    left: 0,
    right: 0,
    alignItems: 'center',
    marginVertical: 3,
  },
  handle: {
    width: 40,
    height: 4,
    backgroundColor: 'darkgray',
    borderRadius: 5,
    marginTop: 4,
    marginBottom: 8,
  },
  drawerBackground: {
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 0 },
    shadowRadius: 3,
    shadowOpacity: 0.3,
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 12,
    borderTopRightRadius: 12,
    position: 'absolute',
    margin: 0,
    padding: 0,
    top: 20,
    bottom: 0,
    left: 0,
    right: 0,
  },
})
