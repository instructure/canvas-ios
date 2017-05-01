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
  state: RubricItemState

  constructor (props: RubricItemProps) {
    super(props)

    this.state = {
      selectedOption: null,
    }
  }

  showDescription = () => {
    this.props.showDescription(this.props.rubricItem.id)
  }

  changeSelected = (id: string) => {
    this.setState({ selectedOption: id })
    let rating = this.props.rubricItem.ratings.find(rating => rating.id === id) || { points: 0 }
    this.props.changeRating(this.props.rubricItem.id, rating.points)
  }

  render () {
    let { rubricItem } = this.props
    return (
      <View style={styles.container}>
        <Text style={styles.description}>{rubricItem.description}</Text>
        <View style={styles.ratings}>
          {rubricItem.ratings.slice().reverse().map(rating => (
            <CircleToggle
              key={rating.id}
              style={styles.circle}
              on={this.state.selectedOption === rating.id}
              value={rating.id}
              onPress={this.changeSelected}
            >
              {rating.points}
            </CircleToggle>
          ))}
          <CircleToggle
            key='add'
            style={styles.circle}
            on={false}
            value=''
            onPress={this.changeSelected}
          >
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
    flexWrap: 'wrap',
    marginTop: 12,
    marginBottom: 8,
  },
  circle: {
    marginRight: 8,
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
  changeRating: (string, number) => void,
}

type RubricItemState = {
  selectedOption: ?string,
}
