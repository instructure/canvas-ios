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
                imageSize={{ height: 24, width: 24 }}
                onPress={this.onPress}
                disclosureIndicator={true}
                border={'bottom'}
                testID={`courses-details.${tab.id}-cell`}
                titleStyles={{ marginLeft: -4, fontWeight: '500' }}/>)
  }
}
