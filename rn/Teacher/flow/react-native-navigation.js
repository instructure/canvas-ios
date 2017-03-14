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

export type ReactNavigator = {
  push: (pushOptions: NavigatorPushOptions) => void,
  pop: () => void,
}
