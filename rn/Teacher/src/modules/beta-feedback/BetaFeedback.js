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

type Props = {
  navigator: ReactNavigator,
  uri: string,
}

export class BetaFeedback extends Component {
  static navigatorButtons = {
    rightButtons: [
      {
        title: i18n({
          default: 'Done',
          description: 'Button to dismiss feedback form.',
          id: 'done_beta_feedback',
        }),
        id: 'dismiss',
        testID: 'beta-feedback.dismiss-btn',
      },
    ],
  }

  constructor (props: Props) {
    super(props)

    this.props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
  }

  render (): React.Element<View> {
    let uri
    const session = getSession()
    if (session) {
      uri = betaFeedbackForm(session.user, device)
    }
    return (
      <WebView
        source={{ uri: uri }}
        testID='beta-feedback.webview'
      />
    )
  }

  onNavigatorEvent = (event: any) => {
    if (event.type === 'NavBarButtonPress') {
      if (event.id === 'dismiss') {
        this.props.navigator.dismissModal()
      }
    }
  }
}

export default BetaFeedback
