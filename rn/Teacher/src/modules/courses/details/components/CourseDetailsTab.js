/**
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component, Element } from 'react'
import {
  View,
} from 'react-native'

import Images from '../../../../images'
import Row from '../../../../common/components/Row'

type Props = {
  tab: Tab,
  courseColor: string,
  onPress: Function,
}

export default class CourseDetails extends Component<any, Props, any> {

  onPress = () => {
    const tab = this.props.tab
    this.props.onPress(tab)
  }

  render (): Element<View> {
    const tab = this.props.tab
    return (<Row
                title={tab.label}
                image={Images.course[tab.id]}
                imageTint={this.props.courseColor}
                imageSize={{ height: 20, width: 21 }}
                onPress={this.onPress}
                disclosureIndicator={true}
                height={44}
                border={'bottom'}
                testID={`courses-details.tab-touchable-row-${tab.id}`} />)
  }
}
