// @flow

import React from 'react'
import {
    View,
    StyleSheet,
    LayoutAnimation,
} from 'react-native'
import { UnmetRequirementBannerText } from '../text'

type Props = {
  visible: boolean,
  text: string,
  backgroundColor: string,
}

export default class UnmetRequirementBanner extends React.Component<any, Props, any> {

  componentWillUpdate () {
    LayoutAnimation.easeInEaseOut()
  }

  render () {
    let bannerStyle = this.props.visible ? styles.visible : styles.hidden

    return (
      <View style={bannerStyle}>
        <View style={styles.textContainer}>
          <UnmetRequirementBannerText style={styles.textContent}>{this.props.text}</UnmetRequirementBannerText>
        </View>
      </View>
    )
  }
}

UnmetRequirementBanner.defaultProps = {
  visible: false,
  text: 'Unmet Requirements',
  backgroundColor: '#EE0612',
}

const styles = StyleSheet.create({
  visible: {
    flex: 0.04,
    alignItems: 'stretch',
    flexDirection: 'column',
    backgroundColor: '#EE0612',
  },
  hidden: {
    flex: 0,
  },
  textContainer: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
  },
  textContent: {
    alignItems: 'center',
    textAlign: 'center',
  },
})
