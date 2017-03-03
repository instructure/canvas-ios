// @flow

import React, { Component, PropTypes } from 'react'
import {
  ActivityIndicator,
  View,
  Text,
  Image,
  Button,
} from 'react-native'
import { connect } from 'react-redux'
import { stateToProps } from './props'
import type { LegoSetsProps } from './props'
import LegoActions from './actions'
import i18n from 'format-message'

export class DisconnectedLegoSets extends Component<any, LegoSetsProps, any> {

  renderLegoSet = (set: LegoSet, index: number) => {
    return (
      <View key={index} testID={set.imageURL}>
        <Image source={{ uri: set.imageURL }} />
        <Text>{ set.name }</Text>
      </View>
    )
  }

  buyTheFalcon = () => {
    this.props.buyLegoSet({
      name: 'The Millenium Falcon',
      imageURL: 'https://lego.com/falcon',
    })
  }

  render (): React.Element<{}> {
    const sets = this.props.sets.map(this.renderLegoSet)
    const activity = this.props.pending > 0
    const indicator = activity ? <ActivityIndicator /> : <View />

    return (
      <View>
        <Text>Lego Sets!</Text>
        {sets}
        {indicator}
        <Text style={{ color: 'red' }}>{this.props.error}</Text>
        <Button
          testID={'toys.legos.buyLegos'}
          title={ i18n('Buy More!') }
          onPress={this.buyTheFalcon} />
        <Button
          title={ i18n('Out of money, sell them all!') }
          onPress={this.props.sellAllLegos} />
      </View>
    )
  }
}

const legoSetShape = PropTypes.shape({
  name: PropTypes.string.isRequired,
  imageURL: PropTypes.string.isRequired,
}).isRequired

DisconnectedLegoSets.propTypes = {
  sets: PropTypes.arrayOf(legoSetShape).isRequired,
  pending: PropTypes.number,
  error: PropTypes.string,
}

export default connect(stateToProps, LegoActions)(DisconnectedLegoSets)
