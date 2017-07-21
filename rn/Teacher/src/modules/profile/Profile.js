import React, { Component } from 'react'
import {
  View,
  NativeModules,
  StyleSheet,
  Image,
  Dimensions,
  ActionSheetIOS,
  Linking,
  AlertIOS,
} from 'react-native'
import i18n from 'format-message'
import { Text, Heading1, Paragraph } from '../../common/text'
import Avatar from '../../common/components/Avatar'
import Screen from '../../routing/Screen'
import Images from '../../images'
import branding from '../../common/branding'
import color from '../../common/colors'
import device from 'react-native-device-info'

const { width: deviceWidth } = Dimensions.get('window')

import { getSession } from '../../api/session'

export default class Profile extends Component {

  logout = () => {
    NativeModules.NativeLogin.logout()
  }

  settings = () => {
    let buttons = [
      i18n('Visit the Canvas Guides'),
      i18n('Report a Problem'),
      i18n('Terms of Use'),
      i18n('Cancel'),
    ]
    ActionSheetIOS.showActionSheetWithOptions({
      options: buttons,
      cancelButtonIndex: buttons.length - 1,
    }, this.handleActions)
  }

  handleActions = (index: number) => {
    switch (index) {
      case 0:
        Linking.openURL('https://community.canvaslms.com/community/answers/guides/mobile-guide/content?filterID=contentstatus%5Bpublished%5D~category%5Btable-of-contents%5D')
        break
      case 1:
        NativeModules.RNMail.mail({
          subject: 'Canvas Teacher - Report a problem',
          recipients: ['support@instructure.com'],
        }, (error, event) => {
          if (error) {
            AlertIOS.alert('Error', i18n('Error sending e-mail'))
          }
        })
        break
      case 2:
        Linking.openURL('https://www.canvaslms.com/policies/terms-of-use')
        break
      default:
        break
    }
  }

  render () {
    const session = getSession()

    if (!session) return null
    const user = session.user
    return (
      <Screen
        navBarHidden={false}
        navBarImage={branding.headerImage}
        navBarButtonColor={color.navBarTextColor}
        navBarColor={color.navBarColor}
        navBarStyle='dark'
        leftBarButtons={[
          {
            image: Images.course.settings,
            testID: 'profile.navigation-settings-btn',
            action: this.settings,
            accessibilityLabel: i18n('Profile actions'),
          },
        ]}
        rightBarButtons={[
          {
            title: i18n('Log Out'),
            testID: 'profile.navigation-logout-btn',
            action: this.logout,
          },
        ]}
      >
        <View testID="module.profile" accessible={true} style={styles.container}>
          <View style={styles.headerImageContainer} >
            <Image source={Images.pencilBG} style={styles.headerImage} />
          </View>
          <View style={styles.profileImageContainer}>
            <Avatar
              avatarURL={user.avatar_url}
              userName={user.name}
              border={true}
              height={160} />
          </View>
          <View style={styles.profileInfoContainer}>
            <Heading1>{user.name}</Heading1>
            <Paragraph>{user.primary_email}</Paragraph>
          </View>
          <View style={styles.versionContainer}>
            <Text style={styles.versionText}>{i18n('Version {version}', { version: device.getReadableVersion() })}</Text>
          </View>
        </View>
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  topContainer: {
    backgroundColor: '#394B58',
    height: 64,
  },
  profileInfoContainer: {
    top: -80,
    alignItems: 'center',
  },
  headerImageContainer: {
    backgroundColor: 'lightgrey',
  },
  headerImage: {
    height: 170,
    width: deviceWidth,
  },
  profileImageContainer: {
    top: -80,
    marginBottom: 20,
    flex: 0,
    flexDirection: 'row',
    justifyContent: 'center',
  },
  versionContainer: {
    bottom: -125,
    alignItems: 'center',
  },
  versionText: {
    color: '#73818C',
    fontSize: 12,
  },
})
