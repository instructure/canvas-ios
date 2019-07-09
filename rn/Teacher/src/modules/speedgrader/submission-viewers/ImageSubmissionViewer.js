//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

import React, { Component } from 'react'
import {
  Image,
  ScrollView,
} from 'react-native'

export default class ImageSubmissionViewer extends Component<{
  attachment: Attachment,
  width: number,
  height: number,
}, {
  width: number,
  height: number,
}> {
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
