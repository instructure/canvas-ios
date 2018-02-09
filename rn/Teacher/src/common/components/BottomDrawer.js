//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

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
import DrawerState, {
  HANDLE_PADDING_BOTTOM,
  HANDLE_INVISIBLE_TOP_PADDING,
  HANDLE_HEIGHT,
  HANDLE_BAR_HEIGHT,
  HANDLE_PADDING_TOP,
  HANDLE_VISIBLE_PADDING,
} from '../../modules/speedgrader/utils/drawer-state'

let { height, width } = Dimensions.get('window')

const cycleText = i18n('Open Drawer')
const snapPointStates = [
  i18n('Full screen'),
  i18n('Half screen'),
  i18n('Closed'),
]

const DrawerHandle = requireNativeComponent('DrawerHandleView')

export type Snap = 0 | 1 | 2
const SNAP_DEFAULT_INDEX = 0

type Props = {
  containerWidth?: number,
  containerHeight?: number,
  children?: React$Node,
  renderHandleContent?: () => any,
  drawerState: DrawerState,
}

type State = {
  height: number,
  width: number,
}

export default class BottomDrawer extends Component<Props, State> {
  state: State = {
    height: this.props.containerHeight || height,
    width: this.props.containerWidth || width,
  }
  _deltaY: Animated.Value = this.props.drawerState.deltaY
  drawer: InteractableView

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

  onDrag = ({ nativeEvent }: { nativeEvent: Object }) => {
    if (nativeEvent.state === 'start') {
      this.props.drawerState.dragBegan()
    }
  }

  onSnap = (e: any) => {
    this.props.drawerState.drawerDidSnap(this, e.nativeEvent.index)
  }

  snapTo = (snap: Snap, animated: boolean = true) => {
    if (this.drawer) {
      this.drawer.snapTo({ index: snap, animated: animated })
    }
  }

  captureDrawer = (d: any) => {
    this.drawer = d
  }

  getSnapPoints = () => {
    const drawerState = this.props.drawerState
    return [0, 1, 2]
      .map(snap => ({
        y: drawerState.drawerSnapPoint(snap, this.state.height),
      }))
  }

  render () {
    let width = Math.min(700, this.state.width)
    let position = (this.state.width - width) / 2

    const snap = this.getSnapPoints().map(point => point.y) // [0, 300, 600]
    const maxSnap = snap[snap.length - 1]
    const heights = [ snap[1], snap[1], maxSnap ] // [300, 300, 600]
    const clampedHeight = this._deltaY.interpolate({
      inputRange: snap,
      outputRange: heights.map(h => h + HANDLE_PADDING_BOTTOM),
    })
    const bottoms = [ -snap[1], 0, 0 ] // [-300, 0, 0]
    const clampedBottom = this._deltaY.interpolate({
      inputRange: snap,
      outputRange: bottoms,
    })
    const hideContentForA11y = this._deltaY.interpolate({
      inputRange: [0, 1, maxSnap],
      outputRange: [0, 1, 1],
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
          onDrag={this.onDrag}
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
          <Animated.View style={{ flex: 1, opacity: hideContentForA11y }}>
            {this.props.children}
          </Animated.View>
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
