// @flow

import React, { Component } from 'react'
import { View, Text } from 'react-native'
import { connect } from 'react-redux'
import { stateToProps } from './props'

class ActionFigures extends Component<any, string, any> {
  render (): React.Element<View> {
    return (
      <View>
        <Text>We are currently not selling action figures. Maybe you would like some Lego Sets?</Text>
      </View>
    )
  }
}

export default connect(stateToProps)(ActionFigures)
