// @flow

import React, { Component } from 'react'
import {
  StyleSheet,
  TouchableHighlight,
  Image,
} from 'react-native'
import Row from '../../common/components/rows/Row'
import images from '../../images'
import colors from '../../common/colors'

export type Props = {
  title: string,
  subtitle: ?string,
  progress: number,
  error: ?string,
  testID: string,
  onRemovePressed: () => void,
  onPress: () => void,
}

export default class AttachmentRow extends Component<any, Props, any> {
  render () {
    return (
      <Row
        title={this.props.title}
        subtitle={this.props.subtitle}
        image={images.attachments.complete}
        imageTint={colors.primaryBrandColor}
        accessories={this.removeButton}
        onPress={this.props.onPress}
        testID={this.props.testID}
      />
    )
  }

  removeButton = (
    <TouchableHighlight
      onPress={this.props.onRemovePressed}
      underlayColor='white'
      hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
    >
      <Image source={images.x} style={styles.remove} />
    </TouchableHighlight>
  )
}

const styles = StyleSheet.create({
  removeContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  remove: {
    width: 14,
    height: 14,
    tintColor: 'black',
  },
})
