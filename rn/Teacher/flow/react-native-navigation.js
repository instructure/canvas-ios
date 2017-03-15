// @flow

export type NavigatorPushOptions = {
  screen: string,
  title?: string,
  titleImage?: any,
  passProps?: any,
  animated?: boolean,
  backButtonTitle?: string,
  backButtonHidden?: boolean,
  navigatorStyle?: any,
  navigatorButtons?: any,
}

export type NavigatorEvent = {
  type: string,
  id: string,
}

export type ShowModalOptions = {
  screen: string,
  title: string,
  passProps?: any,
  navigatorStyle?: any,
  animationType?: string,
}
export type DismissModalOptions = {
  animationType?: string,
}

export type ReactNavigator = {
  showModal: (options: ShowModalOptions) => void,
  dismissModal: (options: ?DismissModalOptions) => void,
  setOnNavigatorEvent: (onNavigatorEvent: Function) => void,
  pop: () => void,
  push: (pushOptions: NavigatorPushOptions) => void,
  pop: () => void,
}
