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
  View,
  Image,
  TouchableOpacity,
} from 'react-native'
import { colors, createStyleSheet } from '../../../common/stylesheet'
import { Title, SubTitle } from '../../../common/text'

export type SubmittedContentDataProps = {
  contentID: string,
  icon: any,
  title: string,
  subtitle: string,
}

export type SubmittedContentActionProps = {
  onPress: Function,
}

type Props
  = SubmittedContentDataProps
  & SubmittedContentActionProps
  & {
    attachmentIndex: number,
    attemptIndex: number,
    submissionID: string,
  }

export default class SubmittedContent extends Component<Props, any> {
  selectContent = () => {
    this.props.onPress(this.props.submissionID, this.props.attemptIndex, this.props.attachmentIndex)
  }

  render () {
    return (
      <TouchableOpacity
        testID={`submitted-content.item-${this.props.contentID}`}
        style={styles.row}
        onPress={this.selectContent}
      >
        <Image
          testID={`submitted-content.icon-${this.props.contentID}`}
          resizeMode='center'
          style={{
            tintColor: colors.buttonPrimaryBackground,
            width: 18,
            height: 18,
          }}
          source={this.props.icon}
        />
        <View style={styles.textContainer} >
          <Title
            testID={`submitted-content.title-${this.props.contentID}`}
            numberOfLines={1}
            ellipsizeMode='tail'
          >
            {this.props.title}
          </Title>
          <SubTitle
            testID={`submitted-content.subtitle-${this.props.contentID}`}
            numberOfLines={1}
            ellipsizeMode='tail'
          >
            {this.props.subtitle}
          </SubTitle>
        </View>
      </TouchableOpacity>
    )
  }
}

const styles = createStyleSheet(colors => ({
  row: {
    flexDirection: 'row',
    borderWidth: 1,
    borderColor: colors.borderMedium,
    borderRadius: 4,
    overflow: 'hidden',
    paddingVertical: 6,
    paddingHorizontal: 8,
    marginBottom: 4,
    width: 265,
  },
  textContainer: {
    flex: 1,
    marginHorizontal: 6,
  },
}))
