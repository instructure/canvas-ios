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

// @flow

import React, { Component } from 'react'
import {
  View,
  Image,
  Dimensions,
  NativeModules,
} from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'
import stateToProps from './map-state-to-props'
import ColorButton from './components/ColorButton'
import CoursesActions from '../actions'
import UserInfoActions from '../../userInfo/actions'
import CourseSettingsActions from '../settings/actions'
import refresh from '../../../utils/refresh'
import { RefreshableScrollView } from '../../../common/components/RefreshableList'
import { Text, TextInput } from '../../../common/text'
import Screen from '../../../routing/Screen'
import Navigator from '../../../routing/Navigator'
import { colors, createStyleSheet } from '../../../common/stylesheet'
import { alertError } from '../../../redux/middleware/error-handler'
import ModalOverlay from '../../../common/components/ModalOverlay'

const HapticFeedback = NativeModules.HapticFeedback

const PICKER_COLOR_WIDTH = 64
const CONTAINER_PADDING = 16 * 2

type Props = {
  navigator: Navigator,
  course: Course,
  color: string,
  showColorOverlay: boolean,
  updateCourseColor: (string, string) => void,
  updateCourseNickname: (Course, string) => Course,
  getUserSettings: () => void,
  pending: number,
  error: ?string,
} & RefreshProps

export class UserCoursePreferences extends Component<Props, any> {
  state = {
    name: this.props.course ? this.props.course.name : '',
    pending: false,
    width: Dimensions.get('window').width,
  }

  onLayout = (event: any) => {
    const { width } = event.nativeEvent.layout
    this.setState({ width })
  }

  course = () => ({
    ...this.props.course,
    name: this.state.name,
  })

  componentWillReceiveProps (props: Props) {
    if (props.error) {
      this.setState({ name: props.course.name, pending: false })
      setTimeout(() => {
        alertError(props.error)
      }, 100)
      return
    }
    if (this.state.pending && !props.pending) {
      this.setState({ pending: false })
      this.props.navigator.dismissAllModals()
    }
  }

  componentDidMount () {
    HapticFeedback.prepare()
  }

  updateColor = (color: string): void => {
    HapticFeedback.generate('selection')
    this.props.updateCourseColor(this.props.course.id, color)
  }

  dismiss = () => {
    if (this.props.course.name !== this.state.name) {
      this.setState({ pending: true })
      this.props.updateCourseNickname(this.props.course, this.state.name)
    } else {
      this.props.navigator.dismiss()
    }
  }

  PICKER_COLORS = {
    '#BD3C14': i18n('Brick'),
    '#FF2717': i18n('Red'),
    '#E71F63': i18n('Magenta'),
    '#8F3E97': i18n('Purple'),
    '#65499D': i18n('Deep Purple'),
    '#4554A4': i18n('Indigo'),
    '#1770AB': i18n('Blue'),
    '#0B9BE3': i18n('Light Blue'),
    '#06A3B7': i18n('Cyan'),
    '#009688': i18n('Teal'),
    '#009606': i18n('Green'),
    '#8D9900': i18n('Olive'),
    '#D97900': i18n('Pumpkin'),
    '#FD5D10': i18n('Orange'),
    '#F06291': i18n('Pink'),
  }

  _hiddenCircles () {
    if (this.state.width > 0) {
      const numOfColors = Object.keys(this.PICKER_COLORS).length
      const perRow = Math.floor((this.state.width - CONTAINER_PADDING) / PICKER_COLOR_WIDTH)
      const numOfRows = Math.floor(numOfColors / perRow)
      const numOnLastRow = numOfColors - (numOfRows * perRow)
      const numOfHiddenCircles = numOnLastRow === 0 ? 0 : perRow - numOnLastRow
      let hiddenCircles = []
      for (let i = 0; i < numOfHiddenCircles; i++) {
        hiddenCircles.push('#FFFFFF00')
      }
      return hiddenCircles
    }
    return []
  }

  _renderColorButtons () {
    let colors = Object.keys(this.PICKER_COLORS).map(color => (
      <ColorButton
        selected={color === this.props.color}
        onPress={this.updateColor}
        color={color}
        colorName={this.PICKER_COLORS[color]}
        key={color}
      />
    ))
    let hidden = this._hiddenCircles().map((color, index) => (
      <ColorButton
        selected={false}
        color={color}
        hidden
        onPress={() => {}}
        key={`hidden${index}`}
      />
    ))
    return [...colors, ...hidden]
  }

  _renderComponent () {
    return (<View style={{ flex: 1 }} onLayout={this.onLayout}>
      <ModalOverlay text={i18n('Saving')} visible={this.state.pending} />
      <RefreshableScrollView
        style={{ flex: 1 }}
        refreshing={this.props.refreshing}
        onRefresh={this.props.refresh}
      >
        <View style={styles.imageWrapper}>
          {this.props.course.image_download_url &&
            <Image source={{ uri: this.props.course.image_download_url }} style={styles.image} />
          }
          {this.props.showColorOverlay &&
            <View
              style={[
                styles.color,
                {
                  backgroundColor: this.props.color,
                  opacity: this.props.course.image_download_url ? 0.8 : 1,
                },
              ]}
            />
          }
        </View>
        <View style={styles.bottom}>
          <View style={styles.row}>
            <Text style={styles.rowTitle}>
              {i18n('Nickname')}
            </Text>
            <TextInput
              value={this.state.name}
              style={styles.nickname}
              onChangeText={(text) => this.setState({ name: text })}
              testID='nameInput'
            />
          </View>
          <View style={styles.separator} />
          <View>
            <Text style={styles.colorLabel}>
              {i18n('Color')}
            </Text>
            <Text style={styles.colorDescription}>
              {i18n('This is your personal color setting. Only you will see this color for the course.')}
            </Text>
            <View style={styles.colorButtonsWrapper}>
              {this._renderColorButtons()}
            </View>
          </View>
          <View style={styles.separator} />
        </View>
      </RefreshableScrollView>
    </View>)
  }

  render () {
    return (
      <Screen
        title={i18n('Customize Course')}
        subtitle={this.state.name}
        drawUnderNavBar={false}
        navBarButtonColor={colors.linkColor}
        navBarTitleColor={colors.textDarkest}
        navBarSubtitleColor={this.props.color}
        rightBarButtons={[{
          title: i18n('Done'),
          style: 'done',
          testID: 'done_button',
          action: this.dismiss,
        }]}
        showDismissButton={false}
      >
        { this._renderComponent() }
      </Screen>
    )
  }
}

export let Refreshed: any = refresh(
  props => {
    props.refreshCourses()
    props.getUserSettings()
  },
  props => !props.course,
  props => Boolean(props.pending)
)(UserCoursePreferences)
const actions = {
  ...CoursesActions,
  ...CourseSettingsActions,
  ...UserInfoActions,
}
let connected = connect(stateToProps, actions)(Refreshed)
export default (connected: UserCoursePreferences)

const styles = createStyleSheet((colors, vars) => ({
  imageWrapper: {
    flex: 1,
    minHeight: 235,
  },
  bottom: {
    flex: 2,
  },
  color: {
    flex: 1,
  },
  image: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
  },
  row: {
    height: 54,
    paddingHorizontal: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  rowTitle: {
    fontWeight: '600',
  },
  nickname: {
    flex: 2,
    paddingLeft: 16,
    marginTop: 18,
    marginBottom: 17,
    height: 19,
    width: 167,
    color: colors.textDarkest,
    fontSize: 16,
    lineHeight: 19,
    textAlign: 'right',
  },
  colorLabel: {
    marginTop: 16,
    marginHorizontal: 16,
    fontWeight: '600',
  },
  colorDescription: {
    marginTop: 2,
    marginHorizontal: 16,
    fontSize: 14,
    color: colors.textDark,
  },
  colorButtonsWrapper: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
  },
  separator: {
    backgroundColor: colors.borderMedium,
    height: vars.hairlineWidth,
  },
}))
