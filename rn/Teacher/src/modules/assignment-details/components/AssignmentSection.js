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
 * @flow
 */

import React, { Component } from 'react'
import { Text } from '../../../common/text'
import color from '../../../common/colors'
import DisclosureIndicator from '../../../common/components/DisclosureIndicator'

import {
  View,
  TouchableHighlight,
  Image,
  StyleSheet,
} from 'react-native'

export default class AssignmentSection extends Component<Object> {
  render () {
    let dividerStyle = {}
    let headerStyle = {}
    if (!this.props.isFirstRow) {
      dividerStyle = assignmentSectionStyles.divider
      headerStyle = assignmentSectionStyles.header
    }

    return (
      <TouchableHighlight onPress={this.props.onPress} testID={this.props.testID}>
        <View style={[assignmentSectionStyles.container, this.props.style]}>
          <View style={dividerStyle}></View>
          <View style={assignmentSectionStyles.innerContainer}>
            <View style={{ flex: 1 }}>
              <View style={assignmentSectionStyles.titleContainer} accessible={Boolean(this.props.accessibilityLabel)} accessibilityLabel={this.props.accessibilityLabel}>
                {
                  this.props.image && <Image source={this.props.image} style={assignmentSectionStyles.image} testID={`${this.props.testID}-title-img`}/>
                }
                { this.props.title && <Text style={headerStyle} testID={`${this.props.testID}-title-lbl`}>{this.props.title}</Text> }
              </View>
              {this.props.children}
            </View>

            { this.props.showDisclosureIndicator && <View style={assignmentSectionStyles.disclosureIndicatorContainer} >
              <DisclosureIndicator style={{ right: 0 }} />
            </View> }
          </View>
        </View>
      </TouchableHighlight>
    )
  }
}

const assignmentSectionStyles = StyleSheet.create({
  container: {
    flex: 1,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
    paddingBottom: global.style.defaultPadding,
    backgroundColor: 'white',
  },
  innerContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  divider: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: color.grey2,
    paddingBottom: global.style.defaultPadding,
  },
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
  },
  header: {
    color: color.grey4,
    fontWeight: '500',
    fontSize: 16,
    paddingTop: 2,
  },
  image: {
    tintColor: color.grey4,
    height: 19,
    width: 19,
    marginRight: 5,
  },
  disclosureIndicatorContainer: {
    flex: 0,
    width: 10,
    paddingRight: 2,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-end',
  },
})
