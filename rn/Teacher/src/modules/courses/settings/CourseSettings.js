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
 * Created by bkraus on 3/8/17.
 * @flow
 */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  TouchableHighlight,
  PickerIOS,
  Image,
  LayoutAnimation,
} from 'react-native'

import i18n from 'format-message'
import colors from '../../../common/colors'
import { mapStateToProps } from './map-state-to-props'
import CourseSettingsActions from './actions'
import ModalOverlay from '../../../common/components/ModalOverlay'
import { alertError } from '../../../redux/middleware/error-handler'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import { Text, TextInput } from '../../../common/text'
import Screen from '../../../routing/Screen'
import Navigator from '../../../routing/Navigator'
import branding from '../../../common/branding'

var PickerItemIOS = PickerIOS.Item

type Props = {
  navigator: Navigator,
  course: Course,
  color: string,
  updateCourse: (Course, Course) => Course,
  pending: number,
  error: ?string,
}

const DISPLAY_NAMES = new Map([
  ['feed', i18n('Course Activity Stream')],
  ['wiki', i18n('Pages Front Page')],
  ['modules', i18n('Course Modules')],
  ['assignments', i18n('Assignments List')],
  ['syllabus', i18n('Syllabus')],
])

export class CourseSettings extends Component<Props, any> {
  constructor (props: Props) {
    super(props)

    this.state = {
      name: this.props.course.original_name ? this.props.course.original_name : this.props.course.name,
      home: this.props.course.default_view,
      pending: false,
    }
  }

  course = () => ({
    ...this.props.course,
    name: this.state.name,
    default_view: this.state.home,
  })

  componentWillReceiveProps (props: Props) {
    if (props.error) {
      this.setState({ pending: false })

      setTimeout(() => {
        alertError(props.error)
      }, 100)
    }
    this.state.pending && !props.pending && !props.error && this.props.navigator.dismissAllModals()
  }

  done = () => {
    this.setState({ pending: true })
    this.props.updateCourse(this.course(), this.props.course)
  }

  _togglePicker = () => {
    let animation = LayoutAnimation.create(250, LayoutAnimation.Types.linear, LayoutAnimation.Properties.opacity)
    LayoutAnimation.configureNext(animation)
    this.setState({ showingPicker: !this.state.showingPicker })
  }

  render () {
    let pickerDetailStyle = this.state.showingPicker ? { color: branding.primaryBrandColor } : {}

    return (
      <Screen
        title={i18n('Course Settings')}
        drawUnderNavBar={false}
        navBarTitleColor={colors.darkText}
        navBarButtonColor={colors.link}
        rightBarButtons={[{
          style: 'done',
          testID: 'course-settings.done-btn',
          title: i18n('Done'),
          action: this.done,
        }]}
        dismissButtonTitle={i18n('Cancel')}
      >
        <View style={{ flex: 1 }}>
          <ModalOverlay text={i18n('Saving')} visible={this.state.pending} />
          <KeyboardAwareScrollView
            style={styles.scrollView}>
            <View style={styles.header}>
              <View style={styles.headerContent}>
                {Boolean(this.props.course.image_download_url) &&
                    <Image source={{ uri: this.props.course.image_download_url }} style={styles.headerContent} />
                }
                <View style={[styles.headerContent, { backgroundColor: this.props.color, opacity: this.props.course.image_download_url ? 0.8 : 1 }]} />
              </View>
            </View>
            <View style={styles.row}>
              <View style={styles.rowContent}>
                <Text style={styles.primaryText} testID='course-settings.name-lbl'>
                  {i18n('Name')}
                </Text>
                <TextInput
                  value={this.state.name}
                  style={styles.actionableText}
                  onChangeText={(text) => this.setState({ name: text })}
                  testID='course-settings.name-input-textbox'
                />
              </View>
            </View>
            <View style={styles.separator}/>
            <TouchableHighlight
              underlayColor="#eee"
              onPress={this._togglePicker}
              testID='course-settings.toggle-home-picker'
            >
              <View style={styles.row}>
                <View style={styles.rowContent}>
                  <Text style={styles.primaryText} testID='course-settings.set-home-lbl'>
                    {i18n(`Set 'Home' to...`)}
                  </Text>
                  <Text
                    style={[styles.actionableText, pickerDetailStyle]}
                    testID='course-settings.home-page-lbl'>
                    { DISPLAY_NAMES.get(this.state.home) }
                  </Text>
                </View>
              </View>
            </TouchableHighlight>
            <View style={styles.separator}/>
            { this.state.showingPicker &&
              <PickerIOS
                style={styles.picker}
                selectedValue={this.state.home}
                onValueChange={(home) => this.setState({ home: home })}
                testID='course-settings.home-picker'>
                {Array.from(DISPLAY_NAMES.keys()).map((key) => (
                  <PickerItemIOS
                    key={key}
                    value={key}
                    label={DISPLAY_NAMES.get(key)}
                  />
                ))}
              </PickerIOS>
            }
            <View
              style={[styles.fakePickerDrawer, { height: this.state.showingPicker ? 0 : 150 }]} />
          </KeyboardAwareScrollView>
        </View>
      </Screen>
    )
  }
}

let connected = connect(mapStateToProps, CourseSettingsActions)(CourseSettings)
export default (connected: CourseSettings)

const styles = StyleSheet.create({
  scrollView: {
    flex: 1,
  },
  header: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 10,
    paddingTop: 20,
    height: 235,
  },
  headerContent: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
  },
  row: {
    flex: 1,
    flexDirection: 'column',
    height: 54,
    paddingHorizontal: 16,
    justifyContent: 'center',
  },
  rowContent: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  primaryText: {
    flex: 2,
    fontWeight: '600',
    fontSize: 16,
    color: colors.darkText,
    lineHeight: 54,
  },
  actionableText: {
    flex: 3,
    color: colors.darkText,
    fontSize: 16,
    textAlign: 'right',
    lineHeight: 54,
  },
  separator: {
    backgroundColor: '#C7CDD1',
    height: StyleSheet.hairlineWidth,
  },
  picker: {
    flex: 1,
  },
  fakePickerDrawer: {
    backgroundColor: 'white',
    flex: 0,
  },
})
