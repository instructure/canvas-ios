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

export type NavigatorShowModalOptions = {
  screen: string,
  title?: string,
  passProps?: any,
  navigatorStyle?: any,
  animationType?: string,
}

export type NavigatorEvent = {
  type: string,
  id: string,
}

export type DismissModalOptions = {
  animationType?: string,
}

export type SetTitleOptions = {
  title: string,
  subtitle?: string,
}

export type ReactNavigator = {
  dismissModal: (options: ?DismissModalOptions) => void,
  setOnNavigatorEvent: (onNavigatorEvent: Function) => void,
  pop: () => void,
  push: (pushOptions: NavigatorPushOptions) => void,
  showModal: (modalOptions: NavigatorShowModalOptions) => void,
  setTitle: (SetTitleOptions) => void,
}

export type NavProps = {
  +navigator: ReactNavigator,
}
