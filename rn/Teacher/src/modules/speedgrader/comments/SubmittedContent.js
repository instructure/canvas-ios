// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  Image,
  TouchableOpacity,
} from 'react-native'
import colors from '../../../common/colors'
import { Title, SubTitle } from '../../../common/text'

export type SubmittedContentDataProps = {
  contentID: string,
  icon: any,
  title: string,
  subtitle: string,
}

export type SubmittedContentActionProps = {
  onPress: () => void,
}

type Props
  = SubmittedContentDataProps
  & SubmittedContentActionProps
  & {
    attachmentIndex: number,
    attemptIndex: number,
    submissionID: string,
  }

export default class SubmittedContent extends Component<any, Props, any> {

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
          style={styles.icon}
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

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    borderWidth: 1,
    borderColor: colors.seperatorColor,
    borderRadius: 4,
    overflow: 'hidden',
    paddingVertical: 6,
    paddingHorizontal: 8,
    marginBottom: 4,
    width: 304,
  },
  icon: {
    tintColor: colors.primaryButton,
  },
  textContainer: {
    flex: 1,
    marginHorizontal: 6,
  },
})
