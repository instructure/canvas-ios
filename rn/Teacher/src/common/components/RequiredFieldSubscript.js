/**
 * @flow
 */

import React from 'react'
import { UnmetRequirementSubscriptText } from '../text'
import {
  View,
  StyleSheet,
  LayoutAnimation,
} from 'react-native'

type Props = {
  title: ?string,
  visible: boolean,
  testID?: string,
}

export default class RequiredFieldSubscript extends React.Component {
  props: Props

  componentWillUpdate () {
    LayoutAnimation.easeInEaseOut()
  }

  render () {
    if (this.props.visible) {
      return (
      <View style={styles.visible}>
        <UnmetRequirementSubscriptText style={styles.subscript} testID={this.props.testID}>{this.props.title}</UnmetRequirementSubscriptText>
      </View>
      )
    } else {
      return (<View/>)
    }
  }
}

const styles = StyleSheet.create({
  visible: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'stretch',
    backgroundColor: '#F5F5F5',
  },
  subscript: {
    marginTop: global.style.defaultPadding / 4,
    marginHorizontal: global.style.defaultPadding,
  },
})
