/**
 * Displays a form for feedback while in beta
 * @flow
 */

import React, { Component } from 'react'
import {
  View,
  WebView,
} from 'react-native'
import i18n from 'format-message'
import { betaFeedbackForm } from './form'
import device from 'react-native-device-info'
import { getSession } from '../../api/session'
import Screen from '../../routing/Screen'
import Navigator from '../../routing/Navigator'
import colors from '../../common/colors'

type Props = {
  navigator: Navigator,
  uri: string,
}

export default class BetaFeedback extends Component<any, Props, any> {

  dismiss = () => {
    this.props.navigator.dismiss()
  }

  render (): React.Element<View> {
    let uri
    const session = getSession()
    if (session) {
      uri = betaFeedbackForm(session.user, device)
    }
    return (
      <Screen
        navBarStyle='light'
        navBarButtonColor={colors.link}
        rightBarButtons={[
          {
            title: i18n('Done'),
            style: 'done',
            testID: 'beta-feedback.dismiss-btn',
            action: this.dismiss,
          },
        ]}
      >
        <WebView
          source={{ uri: uri }}
          testID='beta-feedback.webview'
        />
      </Screen>
    )
  }
}
