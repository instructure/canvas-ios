// @flow

export type Navigator = {
  +show: Function,
  +dismiss: Function,
}

export type NavigationProps = {
  navigator: Navigator,
}
