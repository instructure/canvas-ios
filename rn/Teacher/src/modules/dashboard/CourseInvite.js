//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import i18n from 'format-message'
import React from 'react'
import {
  Image,
  TouchableHighlight,
  View,
  LayoutAnimation,
  NativeModules,
} from 'react-native'
import images from '../../images'
import { createStyleSheet } from '../../common/stylesheet'
import {
  Text,
} from '../../common/text'
import { Button } from '../../common/buttons'
import DashboardContent from './DashboardContent'

const { NativeAccessibility } = NativeModules

type Props = {
  style?: any,
  invite: Invite,
  courseName: string,
  sectionName: string,
  handleInvite: (string, string, string) => any,
  hideInvite?: (string) => any,
}

export default class CourseInvite extends React.Component<Props> {
  UNSAFE_componentWillReceiveProps = (newProps: Props) => {
    const { invite } = newProps
    if (invite.hidden) return
    if (invite.displayState && invite.displayState === 'acted') {
      setTimeout(() => {
        this.setAccessibilityFocus()
      }, 500)
      setTimeout(() => {
        LayoutAnimation.easeInEaseOut()
        this.props.hideInvite && this.props.hideInvite(invite.id)
      }, 3000)
    }
  }

  setAccessibilityFocus = () => {
    NativeAccessibility.focusElement(`CourseInvitation.${this.props.invite.id}.acted`)
  }

  handleInvite = (action: string) => {
    const { invite } = this.props
    this.props.handleInvite(invite.course_id, invite.id, action)
  }

  dismiss = () => {
    this.props.hideInvite && this.props.hideInvite(this.props.invite.id)
  }

  renderCourseSection () {
    const { courseName, sectionName } = this.props
    if (courseName === sectionName) {
      return <Text numberOfLines={1} style={styles.names}>{courseName.trim()}</Text>
    } else {
      return <Text numberOfLines={1} style={styles.names}>{courseName.trim()}, {sectionName.trim()}</Text>
    }
  }

  render () {
    const { style, courseName, invite } = this.props
    if (invite.hidden) return null
    let acceptedOrRejected = invite.enrollment_state === 'active' ? i18n('Invite accepted!') : i18n('Invite declined!')
    return (
      <DashboardContent
        style={style}
        contentStyle={styles.content}
        hideShadow={true}
      >
        <View style={styles.rowContent}>
          <View style={styles.iconContainer}>
            <Image source={images.dashboard.invite} style={styles.icon} />
          </View>
          { invite.displayState === 'acted' ? (
            <View style={styles.inviteDetails} testID={`CourseInvitation.${invite.id}.acted`}>
              <Text style={styles.acted}>{acceptedOrRejected}</Text>
            </View>
          ) : (
            <View style={styles.inviteDetails}>
              <Text style={styles.title}>{i18n('You have been invited')}</Text>
              {this.renderCourseSection()}
              <View style={styles.buttonContainer}>
                <Button
                  onPress={() => this.handleInvite('reject')}
                  style={[styles.buttonText, styles.declineButtonText]}
                  containerStyle={[styles.button, styles.declineButton]}
                  testID={`CourseInvitation.${invite.id}.rejectButton`}
                  accessibilityTraits='button'
                >
                  {i18n('Decline')}
                </Button>
                <Button
                  onPress={() => this.handleInvite('accept')}
                  style={styles.buttonText}
                  containerStyle={styles.button}
                  testID={`CourseInvitation.${invite.id}.acceptButton`}
                  accessibilityTraits='button'
                >
                  {i18n('Accept')}
                </Button>
              </View>
            </View>
          )}
        </View>
        { invite.displayState === 'acted' &&
          <TouchableHighlight
            accessibilityTraits='button'
            accessibilityLabel={i18n(`Dismiss invitation to {name}`, { name: courseName })}
            onPress={this.dismiss}
            underlayColor='transparent'
            style={styles.action}
            testID={`CourseInvitation.${invite.id}.dismissButton`}
          >
            <Image source={images.x} style={styles.dismissIcon} />
          </TouchableHighlight>
        }
      </DashboardContent>
    )
  }
}

const styles = createStyleSheet((colors, vars) => ({
  content: {
    borderColor: colors.borderSuccess,
    borderWidth: 1,
  },
  icon: {
    tintColor: colors.textLightest,
    marginTop: 14,
  },
  rowContent: {
    flexDirection: 'row',
  },
  iconContainer: {
    width: 40,
    alignItems: 'center',
    justifyContent: 'flex-start',
    backgroundColor: colors.backgroundSuccess,
  },
  inviteDetails: {
    flex: 1,
  },
  title: {
    fontWeight: '600',
    fontSize: 18,
    margin: 12,
    marginBottom: 0,
    marginTop: 8,
  },
  acted: {
    fontWeight: '600',
    fontSize: 18,
    margin: 12,
    marginVertical: 13,
  },
  names: {
    marginHorizontal: 12,
    marginBottom: 4,
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
    backgroundColor: colors.backgroundSuccess,
  },
  buttonText: {
    color: colors.white,
    fontSize: 16,
    fontWeight: '600',
  },
  declineButton: {
    backgroundColor: colors.backgroundLightest,
    borderColor: colors.borderDark,
    borderWidth: vars.hairlineWidth,
  },
  declineButtonText: {
    color: colors.textDark,
  },
  action: {
    position: 'absolute',
    right: 0,
    top: 4,
    padding: 12,
  },
  dismissIcon: {
    width: 16,
    tintColor: colors.textDark,
  },
}))
