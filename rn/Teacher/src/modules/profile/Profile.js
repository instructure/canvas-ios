import React, { Component } from 'react'
import {
  View,
  Button,
  NativeModules,
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'
import { Text } from '../../common/text'
import Avatar from '../../common/components/Avatar'

import { getSession } from '../../api/session'

export default class Profile extends Component {

  logout = () => {
    NativeModules.NativeLogin.logout()
  }

  render () {
    const session = getSession()
    const user = session.user
    return (
      <View testID="module.profile" accessible={true} style={styles.container}>
        <View style={styles.headerImage} />
        <View style={styles.bottomContainer}>
          <View style={styles.profileImage}>
            <Avatar
              avatarURL={user.avatar_url}
              userName={user.name}
              height={120} />
          </View>
          <Text style={styles.nameLabel}>{user.name}</Text>
          <Text style={styles.emailLabel}>{user.primary_email}</Text>
          <Button
            onPress={this.logout}
            title={i18n('Logout')} />
        </View>
        </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  bottomContainer: {
    flex: 1,
    alignItems: 'center',
    top: -60,
  },
  headerImage: {
    height: 200,
    backgroundColor: 'lightgrey',
  },
  profileImage: {
    width: 120,
    height: 120,
    marginBottom: 8,
  },
  nameLabel: {
    fontSize: 18,
  },
  emailLabel: {
    color: 'grey',
    fontWeight: '200',
  },
})
