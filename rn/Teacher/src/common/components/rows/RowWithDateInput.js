// @flow

import React, { Component } from 'react'
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

type DateRowProps = {
  title: string,
  date: string,
  showRemoveButton?: boolean,
  onPress: Function,
  onRemoveDatePress: Function,
  testID?: string,
  dateTestID?: string,
  removeButtonTestID?: string,
  selected?: boolean,
}

export default class RowWithDateInput extends Component<any, DateRowProps, any> {

  render () {
    let detailTextStyle = this.props.selected ? { color: branding.primaryBrandColor } : styles.detailText
    let paddingRightWhenEmpty = this.props.showRemoveButton ? 0 : global.style.defaultPadding
    return (
        <View style={[ styles.row, styles.detailsRowContainer ]} >
            <TouchableHighlight style={{ flex: 1 }} onPress={this.props.onPress} testID={this.props.testID}>
              <View style={[styles.rowContainer, { paddingRight: paddingRightWhenEmpty }]}>
                <View style={styles.titlesContainer}>
                    <Text style={styles.titleText}>{this.props.title}</Text>
                </View>
                <View style={styles.detailsRowContainer}>
                  <Text style={detailTextStyle} testID={this.props.dateTestID}>{this.props.date}</Text>
                </View>
              </View>
              </TouchableHighlight>
              {this.props.showRemoveButton &&
                <View style={styles.deleteDateTypeButton}>
                  <TouchableHighlight
                    underlayColor='transparent'
                    onPress={this.props.onRemoveDatePress}
                    accessible={true}
                    accessibilityLabel={i18n('Remove date')}
                    accessibilityTraits='button'
                    testID={this.props.removeButtonTestID}
                    containerStyle={styles.deleteDateTypeButton}>
                      <Image source={Images.clear} />
                  </TouchableHighlight>
                </View>}
            </View>
    )
  }
}

const styles = StyleSheet.create({

  row: {
    height: 54,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.seperatorColor,
    backgroundColor: 'white',
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
  },
  titlesContainer: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
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
