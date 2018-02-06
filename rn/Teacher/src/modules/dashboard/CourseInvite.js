// @flow

import i18n from 'format-message'
import React from 'react'
import {
  Image,
  StyleSheet,
  TouchableHighlight,
  View,
  LayoutAnimation,
  NativeModules,
} from 'react-native'
import images from '../../images'
import colors from '../../common/colors'
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

  componentWillReceiveProps = (newProps: Props) => {
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
    NativeAccessibility.focusElement('course-invite.acted')
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
      return <Text numberOfLines={1} style={styles.names}>{courseName}</Text>
    } else {
      return <Text numberOfLines={1} style={styles.names}>{courseName}, {sectionName}</Text>
    }
  }

  render () {
    const { style, courseName, invite } = this.props
    if (invite.hidden) return null
    let acceptedOrRejected = null
    if (invite.displayState === 'acted') {
      acceptedOrRejected = invite.enrollment_state === 'active' ? i18n('Invite accepted!') : i18n('Invite declined!')
    }
    const color = colors.checkmarkGreen
    const declineColor = {
      borderColor: colors.gray4,
    }
    return (
      <DashboardContent
        style={style}
        contentStyle={[{ borderColor: color, borderWidth: 1 }]}
      >
        <View style={styles.rowContent}>
          <View style={[styles.iconContainer, { backgroundColor: color }]}>
            <Image source={images.dashboard.invite} style={styles.icon} />
          </View>
          { invite.displayState === 'acted' ? (
            <View style={styles.inviteDetails} testID='course-invite.acted'>
              <Text style={styles.title}>{acceptedOrRejected}</Text>
            </View>
          ) : (
            <View style={styles.inviteDetails}>
              <Text style={styles.title}>{i18n('You have been invited')}</Text>
              {this.renderCourseSection()}
              <View style={styles.buttonContainer}>
                <Button
                  onPress={() => this.handleInvite('reject')}
                  style={{ color: colors.lightText, fontWeight: '600' }}
                  containerStyle={[styles.button, styles.declineButton, declineColor]}
                  testID={`course-invite.${invite.id}.reject-button`}
                  accessibilityTraits='button'
                  >{i18n('Decline')}</Button>
                <Button
                  onPress={() => this.handleInvite('accept')}
                  style={{ color: colors.primaryButtonText, fontWeight: '600' }}
                  containerStyle={[styles.button, { backgroundColor: color }]}
                  testID={`course-invite.${invite.id}.accept-button`}
                  accessibilityTraits='button'
                >{i18n('Accept')}</Button>
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
            testID={`course-invite.${invite.id}.dismiss-button`}
          >
            <Image source={images.x} style={styles.dismissIcon} />
          </TouchableHighlight>
        }
      </DashboardContent>
    )
  }
}

const styles = StyleSheet.create({
  icon: {
    tintColor: 'white',
    marginTop: 14,
  },
  rowContent: {
    flexDirection: 'row',
  },
  iconContainer: {
    width: 40,
    alignItems: 'center',
    justifyContent: 'flex-start',
  },
  inviteDetails: {
    margin: 8,
    flex: 1,
  },
  title: {
    fontWeight: '600',
    fontSize: 18,
    marginRight: 32,
    marginBottom: 4,
    marginTop: 4,
  },
  names: {
    marginBottom: 6,
  },
  buttonContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-start',
    flexWrap: 'wrap',
  },
  button: {
    width: 136,
    height: 40,
    borderRadius: 4,
    marginBottom: 4,
  },
  declineButton: {
    backgroundColor: 'white',
    borderWidth: StyleSheet.hairlineWidth,
    marginRight: 8,
  },
  action: {
    position: 'absolute',
    right: 0,
    top: 0,
    padding: 12,
  },
  dismissIcon: {
    width: 16,
    tintColor: colors.grey4,
  },
})
