/**
* Launching pad for navigation for a single course
* @flow
*/

import React from 'react'
import {
} from 'react-native'

import Images from '../../../../images'
import Row from '../../../../common/components/rows/Row'

type Props = {
  tab: Tab,
  courseColor: string,
  onPress: Function,
}

export default class CourseDetails extends React.Component<any, Props, any> {

  onPress = () => {
    const tab = this.props.tab
    this.props.onPress(tab)
  }

  render () {
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
                testID={`courses-details.${tab.id}-cell`} />)
  }
}
