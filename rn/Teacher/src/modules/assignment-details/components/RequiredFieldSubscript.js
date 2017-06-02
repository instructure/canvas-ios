/**
 * @flow
 */

import React, { Component } from 'react'
import { UnmetRequirementSubscriptText } from '../../../common/text'
import {
  View,
  StyleSheet,
  LayoutAnimation,
} from 'react-native'

type Props = {
  title: string,
  visible: boolean,
}

export default class RequiredFieldSubscript extends Component {
  props: Props

  componentWillUpdate () {
    LayoutAnimation.easeInEaseOut()
  }

  render (): ReactElement<*> {
    let visibility = this.props.visible ? styles.visible : styles.hidden

    return (
      <View style={visibility}>
        <UnmetRequirementSubscriptText style={styles.subscript}>{this.props.title}</UnmetRequirementSubscriptText>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  visible: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'stretch',
    height: 20,
    backgroundColor: '#F5F5F5',
  },
  hidden: {
    height: 0,
  },
  subscript: {
    marginTop: global.style.defaultPadding / 4,
    marginHorizontal: global.style.defaultPadding,
  },
})
