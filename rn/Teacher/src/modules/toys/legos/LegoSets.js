// @flow

import React, { Component, PropTypes } from 'react'
import {
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
    const sets = this.props.legoSets.map(this.renderLegoSet)

    return (
      <View>
        <Text>Lego Sets!</Text>
        {sets}
        <Button
          testID='toys.legos.buyLegos'
          title={ i18n('Buy More!') }
          onPress={this.buyTheFalcon} />
        </View>
    )
  }
}

const legoSetShape = PropTypes.shape({
  name: PropTypes.string.isRequired,
  imageURL: PropTypes.string.isRequired,
}).isRequired

DisconnectedLegoSets.propTypes = {
  legoSets: PropTypes.arrayOf(legoSetShape).isRequired,
}

export default connect(stateToProps, LegoActions)(DisconnectedLegoSets)
