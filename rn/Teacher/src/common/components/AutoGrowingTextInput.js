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

import React, { PureComponent } from 'react'
import { TextInput } from 'react-native'

type State = { height: number }
type Props = {
  defaultHeight: number,
  style?: any,
  onContentSizeChange?: Function,
}

export default class AutoGrowingTextInput extends PureComponent<Props, State> {
  state: State = { height: this.props.defaultHeight }

  updateContentSize = (e: any) => {
    // By adding a few pixels to the height of this content size, it ensures that the view will not scroll
    this.setState({ height: Math.max(e.nativeEvent.contentSize.height + 5, this.props.defaultHeight) })
    this.props.onContentSizeChange && this.props.onContentSizeChange(e)
  }

  render () {
    return (
      <TextInput
        {...this.props}
        style={[this.props.style, { height: this.state.height }]}
        multiline
        onContentSizeChange={this.updateContentSize}
      />
    )
  }
}
