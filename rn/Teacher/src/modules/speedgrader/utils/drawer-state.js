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

import { Animated, Keyboard } from 'react-native'

export type DrawerPosition = 0 | 1 | 2
export type DrawerObserver = {
  snapTo: (position: DrawerPosition, animated?: boolean) => void,
  onDragBegan?: () => void,
}

export const HANDLE_PADDING_BOTTOM: number = 52
export const HANDLE_INVISIBLE_TOP_PADDING: number = 16
export const HANDLE_VISIBLE_PADDING: number = 6
export const HANDLE_PADDING_TOP: number = HANDLE_INVISIBLE_TOP_PADDING + HANDLE_VISIBLE_PADDING
export const HANDLE_BAR_HEIGHT: number = 4
export const HANDLE_HEIGHT: number = HANDLE_PADDING_TOP + HANDLE_PADDING_BOTTOM + HANDLE_BAR_HEIGHT
// space the drawer will not enter when fully open
const DRAWER_MIN_TOP_PADDING = 60 - HANDLE_INVISIBLE_TOP_PADDING

export default class DrawerState {
  currentSnap: DrawerPosition
  deltaY: Animated.Value
  drawers: Array<DrawerObserver>
  commentProgress: { [string]: Animated.Value }

  drawerHeight (position: DrawerPosition, screenHeight: number): number {
    return this.drawerSnapPoint(position, screenHeight) + HANDLE_HEIGHT - HANDLE_INVISIBLE_TOP_PADDING
  }

  drawerSnapPoint (position: DrawerPosition, screenHeight: number): number {
    const minHeight = Math.max(screenHeight, 140) // for tests
    switch (position) {
      case 1: return minHeight * 0.5 - HANDLE_PADDING_BOTTOM
      case 2: return minHeight - HANDLE_HEIGHT - DRAWER_MIN_TOP_PADDING
      default: return 0
    }
  }

  constructor () {
    this.currentSnap = 0
    this.deltaY = new Animated.Value(0)
    this.drawers = []
    this.commentProgress = {}
  }

  registerDrawer (drawer: DrawerObserver) {
    drawer.snapTo(this.currentSnap, false)
    this.drawers.push(drawer)
  }

  unregisterDrawer (drawer: DrawerObserver) {
    this.drawers = this.drawers.filter(registered => registered !== drawer)
  }

  dragBegan = () => {
    this.drawers.forEach(drawer => drawer.onDragBegan && drawer.onDragBegan())
  }

  drawerDidSnap = (drawer: DrawerObserver, snap: DrawerPosition) => {
    this.snapTo(snap, false, drawer)
    if (snap !== 2) {
      Keyboard.dismiss()
    }
  }

  snapTo = (snap: DrawerPosition, animated: boolean = true, initiatingDrawer?: DrawerObserver) => {
    if (snap !== this.currentSnap) {
      this.currentSnap = snap
      this.drawers.forEach(drawer => drawer !== initiatingDrawer && drawer.snapTo(snap, animated))
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
