// @flow

import React, { Component } from 'react'
import {
  View,
} from 'react-native'
import i18n from 'format-message'

type Props = {
  navigator: ReactNavigator,
}

export default class Speedgrader extends Component {
  props: Props

  static navigatorButtons = {
    rightButtons: [{
      title: i18n('Done'),
      id: 'done',
      testId: 'done_button',
    }],
  }

  constructor (props: Props) {
    super(props)

    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
    props.navigator.setTitle({
      title: i18n({
        default: 'Speedgrader',
        description: 'Grade student submissions',
      }),
    })
  }

  onNavigatorEvent = (event: NavigatorEvent): void => {
    if (event.type === 'NavBarButtonPress') {
      if (event.id === 'done') {
        this.props.navigator.dismissModal()
      }
    }
  }

  render (): React.Element<{}> {
    return <View></View>
  }
}
