//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

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
  attendanceTabID: ?string,
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
                image={tab.id === this.props.attendanceTabID ? Images.course.attendance : Images.course[tab.id]}
                imageTint={this.props.courseColor}
                imageSize={{ height: 24, width: 24 }}
                onPress={this.onPress}
                disclosureIndicator={true}
                border={'bottom'}
                testID={`courses-details.${tab.id}-cell`}
                titleStyles={{ marginLeft: -4, fontWeight: '500' }}/>)
  }
}
