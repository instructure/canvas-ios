// @flow

import React, { Component } from 'react'
import {
  View,
  Image,
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'
import { Text } from '../../../common/text'
import { CircleToggle, LinkButton } from '../../../common/buttons'
import Images from '../../../images'

export default class RubricItem extends Component {
  props: RubricItemProps

  showDescription = () => {
    this.props.showDescription(this.props.rubricItem.id)
  }

  render () {
    let { rubricItem } = this.props
    return (
      <View style={styles.container}>
        <Text style={styles.description}>{rubricItem.description}</Text>
        <View style={styles.ratings}>
          {rubricItem.ratings.slice().reverse().map(rating => (
            <CircleToggle key={rating.points} style={styles.circle} on={false}>{rating.points}</CircleToggle>
          ))}
          <CircleToggle key='add' style={styles.circle} on={false}>
            <Image source={Images.add} />
          </CircleToggle>
        </View>
        <View style={styles.buttons}>
          <LinkButton style={styles.button}>{i18n('Add Comment')}</LinkButton>
          <LinkButton
            style={styles.button}
            onPress={this.showDescription}
            testID='rubric-item.description'
          >
            {i18n('View long description')}
          </LinkButton>
        </View>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    paddingTop: 16,
    paddingBottom: 8,
  },
  description: {
    fontWeight: '600',
  },
  ratings: {
    flexDirection: 'row',
    marginTop: 12,
    marginBottom: 8,
  },
  circle: {
    marginRight: 12,
    marginBottom: 8,
  },
  buttons: {
    flexDirection: 'row',
  },
  button: {
    fontSize: 14,
    fontWeight: '500',
    paddingRight: 16,
  },
})

type RubricItemProps = {
  rubricItem: Rubric,
  showDescription: (string) => void,
}
