// @flow

import React from 'react'
import { View, Image, StyleSheet } from 'react-native'
import Button from 'react-native-button'
import Images from '../../images'
import i18n from 'format-message'

export default class NavigationBackButton extends React.Component {
  render () {
    return <Button style={styles.backButton} {...this.props}>
            <View style={{ paddingRight: 31 }} accessible={true} accessibilityTraits={'button'} accessibilityLabel={i18n('Back')}>
              <Image source={Images.backIcon} style={styles.navButtonImage} />
            </View>
           </Button>
  }
}

const styles = StyleSheet.create({
  backButton: {
    color: 'white',
    backgroundColor: 'transparent',
  },
})
