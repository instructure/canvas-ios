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

import i18n from 'format-message'
import React from 'react'
import {
  Image,
  LayoutAnimation,
  StyleSheet,
  TouchableHighlight,
  View,
  NativeModules,
} from 'react-native'
import images from '../../images'
import colors from '../../common/colors'
import { Heading2 } from '../../common/text'
import { Button } from '../../common/buttons'
import DashboardContent from './DashboardContent'
import { logEvent } from '../../common/CanvasAnalytics'

type Props = NavigationProps & {
  collapsed: boolean,
  style: ?{[string]: any},
}

type State = {
  collapsed: boolean,
}

export default class AppRatingPrompt extends React.Component<Props, State> {
  state = {
    collapsed: this.props.collapsed,
  }

  componentWillReceiveProps (newProps: Props) {
    this.state.collapsed = newProps.collapsed
  }

    dismiss = () => {
      NativeModules.AppStoreReview.handleUserFeedbackOnDashboard(false)
      this.hide()
    }

    hide = () => {
      LayoutAnimation.easeInEaseOut()
      this.setState({ collapsed: true })
    }

    render () {
      const { style } = this.props
      let { collapsed } = this.state

      return (
        <DashboardContent
          style={[style, (collapsed ? styles.collapsed : styles.expanded)]}
          contentStyle={[{ borderColor: 'transparent', borderWidth: 0 }]}
          hideShadow={true}
        >
          <View style={styles.rowContent}>
            <TouchableHighlight
              accessibilityTraits='button'
              accessibilityLabel={i18n(`Dismiss prompt to rate`)}
              onPress={this.dismiss}
              underlayColor='transparent'
              style={styles.closeButtonContainer}
              testID={`prompt-to-rate.butotn.dismiss`}
            >
              <Image source={images.x} style={styles.dismissIcon} />
            </TouchableHighlight>
            <Heading2 style={styles.header}> {i18n('Are you enjoying Canvas?')} </Heading2>
          </View>

          <View style={styles.buttonContainer}>
            <Button
              onPress={() => this.handleResponse(false)}
              style={[styles.buttonText]}
              containerStyle={[styles.button]}
              testID={`prompt-to-rate.button.no`}
              accessibilityTraits='button'
            >
              {i18n('No')}
            </Button>
            <Button
              onPress={() => this.handleResponse(true)}
              style={styles.buttonText}
              containerStyle={styles.button}
              testID={`prompt-to-rate.button.yes`}
              accessibilityTraits='button'
            >
              {i18n('Yes')}
            </Button>
          </View>
        </DashboardContent>
      )
    }

    handleResponse = (userAcceptedAppReview: boolean) => {
      let event
      NativeModules.AppStoreReview.handleUserFeedbackOnDashboard(userAcceptedAppReview)
      if (userAcceptedAppReview) {
        event = 'appReview_userAccepted'
      } else {
        event = 'appReview_userDeclined'
        this.promptUserForFeedback()
      }
      logEvent(event)
      this.hide()
    }

    promptUserForFeedback = () => {
      this.props.navigator.show('/support/problem', { modal: true })
    }
}

const styles = StyleSheet.create({
  closeButtonContainer: {
    position: 'absolute',
    right: 0,
    top: 0,
    padding: 12,
  },
  header: {
    textAlign: 'center',
    fontWeight: '600',
  },
  buttonContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-start',
    flexWrap: 'wrap',
    margin: 8,
  },
  button: {
    flex: 1,
    height: 40,
    borderRadius: 4,
    margin: 4,
    backgroundColor: 'white',
    borderColor: colors.grey4,
    borderWidth: StyleSheet.hairlineWidth,
  },
  buttonText: {
    color: colors.link,
    fontSize: 16,
    fontWeight: '600',
  },
  rowContent: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    padding: 8,
  },

  dismiss: {
    alignSelf: 'flex-end',
    paddingHorizontal: 4,
    paddingVertical: 2,
  },
  dismissIcon: {
    width: 16,
    tintColor: colors.grey4,
  },
  collapsed: {
    height: 0,
    overflow: 'hidden',
  },
  expanded: {
    overflow: 'hidden',
  },
})
