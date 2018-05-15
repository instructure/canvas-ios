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

// @flow

import React, { PureComponent } from 'react'
import {
  View,
  StyleSheet,
  TouchableHighlight,
  Image,
} from 'react-native'
import { Text } from '../../text'
import i18n from 'format-message'
import colors from '../../colors'
import Images from '../../../images'
import branding from '../../branding'
import { extractDateFromString } from '../../../utils/dateUtils'

type DateRowProps = {
  title: string,
  date: ?string,
  showRemoveButton?: boolean,
  onPress?: Function,
  onRemoveDatePress?: Function,
  testID?: string,
  dateTestID?: string,
  removeButtonTestID?: string,
  selected?: boolean,
}

export default class RowWithDateInput extends PureComponent<DateRowProps, any> {
  render () {
    let detailTextStyle = this.props.selected ? { color: branding.primaryBrandColor } : styles.detailText
    let paddingRightWhenEmpty = this.props.showRemoveButton ? 0 : global.style.defaultPadding

    let date = extractDateFromString(this.props.date)
    date = date ? i18n("{ date, date, 'MMM d' } { date, time, short }", { date }) : i18n('--')
    return (
      <View style={[ styles.row, styles.detailsRowContainer ]} >
        <TouchableHighlight style={{ flex: 1 }} onPress={this.props.onPress} testID={this.props.testID}>
          <View style={[styles.rowContainer, { paddingRight: paddingRightWhenEmpty }]}>
            <View style={styles.titlesContainer}>
              <Text style={styles.titleText}>{this.props.title}</Text>
            </View>
            <View style={styles.detailsRowContainer}>
              <Text style={detailTextStyle} testID={this.props.dateTestID}>{date}</Text>
            </View>
          </View>
        </TouchableHighlight>
        { this.props.showRemoveButton &&
          <View style={styles.deleteDateTypeButton}>
            <TouchableHighlight
              underlayColor='transparent'
              onPress={this.props.onRemoveDatePress}
              accessible={true}
              accessibilityLabel={i18n('Remove date')}
              accessibilityTraits='button'
              testID={this.props.removeButtonTestID}
              containerStyle={styles.deleteDateTypeButton}
            >
              <Image source={Images.clear} />
            </TouchableHighlight>
          </View>
        }
      </View>
    )
  }
}

const styles = StyleSheet.create({

  row: {
    paddingVertical: global.style.defaultPadding / 2,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.seperatorColor,
    backgroundColor: 'white',
    minHeight: 54,
  },
  rowContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: 'white',
    paddingLeft: global.style.defaultPadding,
  },
  detailsRowContainer: {
    justifyContent: 'flex-end',
    flexDirection: 'row',
    alignItems: 'center',
    minWidth: 90,
  },
  titlesContainer: {
    paddingRight: 32,
  },
  titleText: {
    fontWeight: '600',
  },
  detailText: {
  },
  deleteDateTypeButton: {
    paddingTop: 8,
    paddingBottom: 8,
    paddingLeft: 8,
    paddingRight: global.style.defaultPadding,
    alignItems: 'center',
    justifyContent: 'center',
  },
})
