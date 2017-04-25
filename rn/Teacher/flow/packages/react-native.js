// @flow

declare var console: typeof console & { disableYellowBox: boolean }

export type PanResponderGestureState = {
  stateID: number,
  moveX: number,
  moveY: number,
  x0: number,
  y0: number,
  dx: number,
  dy: number,
  vx: number,
  vy: number,
}

export type KeyboardEventData = {
  endCoordinates: {
    width: number,
    height: number,
    screenX: number,
    screenY: number,
  },
}
