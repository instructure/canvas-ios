// @flow

import { Animated } from 'react-native'
import BottomDrawer, { type Snap } from '../../../common/components/BottomDrawer'

export default class DrawerState {
  currentSnap: Snap
  deltaY: Animated.Value
  drawers: Array<BottomDrawer>
  commentProgress: { [string]: Animated.Value }

  constructor () {
    this.currentSnap = 0
    this.deltaY = new Animated.Value(0)
    this.drawers = []
    this.commentProgress = {}
  }

  registerDrawer (drawer: BottomDrawer) {
    drawer.snapTo(this.currentSnap, false)
    this.drawers.push(drawer)
  }

  unregisterDrawer (drawer: BottomDrawer) {
    this.drawers = this.drawers.filter(registered => registered !== drawer)
  }

  didSnapTo = (snap: Snap) => {
    this.snapTo(snap, false)
  }

  snapTo = (snap: Snap, animated: boolean = true) => {
    if (snap !== this.currentSnap) {
      this.currentSnap = snap
      this.drawers.forEach(drawer => drawer.snapTo(snap, animated))
      if (!animated && snap === 0) {
        this.deltaY.setValue(0)
      }
    }
  }

  registerCommentProgress = (userID: string, value: Animated.Value) => {
    this.commentProgress[userID] = value
  }

  unregisterCommentProgress = (userID: string) => {
    delete this.commentProgress[userID]
  }
}
