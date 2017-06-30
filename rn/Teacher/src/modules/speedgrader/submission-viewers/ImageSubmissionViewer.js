// @flow

import React, { Component } from 'react'
import {
  Image,
  ScrollView,
} from 'react-native'

export default class ImageSubmissionViewer extends Component {
  state: {
    width: number,
    height: number,
  }
  props: {
    attachment: Attachment,
    width: number,
    height: number,
  }

  componentDidMount () {
    Image.getSize(this.props.attachment.url, (width, height) => {
      let maxWidth = Math.min(this.props.width, width) - 32
      let maxHeight = maxWidth * (height / width)
      this.setState({
        width: maxWidth,
        height: maxHeight,
      })
    })
  }

  render () {
    return (
      <ScrollView
        maximumZoomScale={2.0}
        minimumZoomScale={0.5}
        showsHorizontalScrollIndicator
        showsVerticalScrollIndicator
        style={{ paddingHorizontal: 16 }}
      >
        <Image
          resizeMode='contain'
          source={{ uri: this.props.attachment.url }}
          style={this.state} />
      </ScrollView>
    )
  }
}
