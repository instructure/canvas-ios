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
 * @flow
 */

import React, { Component } from 'react'
import { Text } from '../../../common/text'
import { createStyleSheet } from '../../../common/stylesheet'
import DisclosureIndicator from '../../../common/components/DisclosureIndicator'

import {
  View,
  TouchableHighlight,
  Image,
} from 'react-native'

export default class AssignmentSection extends Component<Object> {
  render () {
    let dividerStyle = {}
    let headerStyle = {}
    if (!this.props.isFirstRow) {
      dividerStyle = assignmentSectionStyles.divider
      headerStyle = assignmentSectionStyles.header
    }
    const Wrapper = this.props.onPress ? TouchableHighlight : View

    return (
      <Wrapper onPress={this.props.onPress} testID={this.props.testID}>
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
      </Wrapper>
    )
  }
}

const assignmentSectionStyles = createStyleSheet((colors, vars) => ({
  container: {
    flex: 1,
    paddingLeft: vars.padding,
    paddingRight: vars.padding,
    paddingBottom: vars.padding,
    backgroundColor: colors.backgroundLightest,
  },
  innerContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  divider: {
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
    paddingBottom: vars.padding,
  },
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
  },
  header: {
    color: colors.textDark,
    fontWeight: '500',
    fontSize: 16,
    paddingTop: 2,
  },
  image: {
    tintColor: colors.textDark,
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
}))
