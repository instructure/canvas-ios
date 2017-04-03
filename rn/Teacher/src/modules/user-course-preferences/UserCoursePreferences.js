// @flow

import React, { Component } from 'react'
import {
  ScrollView,
  View,
  StyleSheet,
  Image,
  Text,
} from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'
import stateToProps from './state-to-props'
import { branding } from '../../common/branding'
import ColorButton from './components/ColorButton'
import CoursesActions from '../courses/actions'
import refresh from '../../utils/refresh'
import { RefreshableScrollView } from '../../common/components/RefreshableList'

const PICKER_COLORS = [
  '#F26090', '#EA1661', '#903A99', '#65469F', '#4452A6',
  '#1482C8', '#2CA3DE', '#00BCD5', '#009788', '#3FA142',
  '#89C540', '#FFC100', '#FA9800', '#F2581B', '#F2422E',
]

type Props = {
  navigator: ReactNavigator,
  course: Course,
  color: string,
  updateCourseColor: (string, string) => void,
  pending: number,
  refresh: Function,
}

export class UserCoursePreferences extends Component {
  props: Props

  static navigatorButtons = {
    rightButtons: [{
      title: i18n('Done'),
      id: 'done',
      testId: 'done_button',
    }],
  }

  constructor (props: Props) {
    super(props)

    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
    props.navigator.setTitle({
      title: i18n({
        default: 'Customize Course',
        description: 'The title of the user course preferences screen',
      }),
    })
  }

  onNavigatorEvent = (event: NavigatorEvent): void => {
    if (event.type === 'NavBarButtonPress') {
      if (event.id === 'done') {
        this.props.navigator.dismissModal()
      }
    }
  }

  updateColor = (color: string): void => {
    this.props.updateCourseColor(this.props.course.id, color)
  }

  render (): React.Element<*> {
    return (
      <RefreshableScrollView
        style={{ flex: 1 }}
        refreshing={Boolean(this.props.pending)}
        onRefresh={this.props.refresh}
      >
        <View style={styles.imageWrapper}>
          {this.props.course.image_download_url &&
            <Image source={{ uri: this.props.course.image_download_url }} style={styles.image} />
          }
          <View
            style={[
              styles.color,
              {
                backgroundColor: this.props.color,
                opacity: this.props.course.image_download_url ? 0.8 : 1,
              },
            ]}
          />
        </View>
        <View style={styles.bottom}>
          <View style={styles.nicknameWrapper}>
            <Text style={styles.nicknameLabel}>
              {i18n({
                default: 'Nickname',
                description: 'Text describing a nick name given to a course',
              })}
            </Text>
            <Text style={styles.nickname}>{this.props.course.name}</Text>
          </View>
          <View style={styles.colorPicker}>
            <Text style={styles.colorLabel}>
              {i18n({
                default: 'Color',
                description: 'Title label for the course color picker',
              })}
            </Text>
            <Text style={styles.colorDescription}>
              {i18n({
                default: 'Set this for the default color of the course. This won’t override a personal color setting.',
                description: 'Description of color picker shown to the user',
              })}
            </Text>
            <ScrollView contentContainerStyle={styles.colorButtonsWrapper} horizontal showsHorizontalScrollIndicator={false}>
              {PICKER_COLORS.map(color => (
                <ColorButton
                  selected={color === this.props.color}
                  onPress={this.updateColor}
                  color={color}
                  key={color}
                />
              ))}
            </ScrollView>
          </View>
        </View>
      </RefreshableScrollView>
    )
  }
}

let Refreshed = refresh(
  props => props.refreshCourses(),
  props => !props.course
)(UserCoursePreferences)
let connected = connect(stateToProps, CoursesActions)(Refreshed)
export default (connected: UserCoursePreferences)

const styles = StyleSheet.create({
  imageWrapper: {
    flex: 1,
    minHeight: 200,
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
  nicknameWrapper: {
    height: 54,
    paddingHorizontal: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  nicknameLabel: {
    fontSize: 16,
    fontWeight: '500',
  },
  nickname: {
    color: branding.primaryButtonColor,
    fontSize: 16,
    fontWeight: '500',
  },
  colorPicker: {
    borderColor: '#C7CDD1',
    borderTopWidth: 1,
    borderBottomWidth: 1,
  },
  colorLabel: {
    marginTop: 16,
    marginHorizontal: 16,
    fontSize: 16,
    fontWeight: '500',
  },
  colorDescription: {
    marginTop: 2,
    marginHorizontal: 16,
    fontSize: 14,
    fontWeight: '500',
    color: '#8B969E',
  },
  colorButtonsWrapper: {
    padding: 8,
  },
})
