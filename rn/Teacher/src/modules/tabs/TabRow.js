//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/**
* Launching pad for navigation for a single course
* @flow
*/

import React from 'react'
import { SafeAreaView, Image } from 'react-native'
import i18n from 'format-message'

import Images from '../../images'
import Row from '../../common/components/rows/Row'

type Props = {
  tab: Tab,
  color: string,
  onPress: Function,
  attendanceTabID: ?string,
  selected: ?boolean,
}

export default class TabRow extends React.Component<Props> {
  onPress = () => {
    const tab = this.props.tab
    this.props.onPress(tab)
  }

  image = () => {
    const tab = this.props.tab
    let image = Images.course[tab.id]
    if (tab.id === this.props.attendanceTabID) {
      return Images.course.attendance
    }
    if (tab.id.match(/external_tool/)) {
      return Images.course.lti
    }

    if (!image) {
      image = Images.course.placeholder
    }

    return image
  }

  render () {
    const tab = this.props.tab
    return (<SafeAreaView>
      <Row
        title={tab.label}
        image={this.image()}
        imageTint={this.props.color}
        imageSize={{ height: 24, width: 24 }}
        onPress={this.onPress}
        disclosureIndicator
        border='bottom'
        selected={this.props.selected}
        testID={`courses-details.${tab.id}-cell`}
        accessories={tab.hidden &&
            <Image source={Images.invisible} accessibilityLabel={i18n('Hidden')} />
        }
      />
    </SafeAreaView>)
  }
}
