// @flow

import React, { Component } from 'react'
import {
  ScrollView,
  View,
  StyleSheet,
  Image,
  Alert,
} from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'
import stateToProps from './map-state-to-props'
import ColorButton from './components/ColorButton'
import CoursesActions from '../actions'
import CourseSettingsActions from '../settings/actions'
import refresh from '../../../utils/refresh'
import { RefreshableScrollView } from '../../../common/components/RefreshableList'
import { Text, TextInput } from '../../../common/text'
import Screen from '../../../routing/Screen'
import Navigator from '../../../routing/Navigator'
import colors from '../../../common/colors'
import { ERROR_TITLE } from '../../../redux/middleware/error-handler'
import ModalActivityIndicator from '../../../common/components/ModalActivityIndicator'

const PICKER_COLORS = [
  '#F26090', '#EA1661', '#903A99', '#65469F', '#4452A6',
  '#1482C8', '#2CA3DE', '#00BCD5', '#009788', '#3FA142',
  '#89C540', '#FFC100', '#FA9800', '#F2581B', '#F2422E',
]

type Props = {
  navigator: Navigator,
  course: Course,
  color: string,
  updateCourseColor: (string, string) => void,
  updateCourse: (Course, Course) => Course,
  pending: number,
  error: ?string,
} & RefreshProps

export class UserCoursePreferences extends Component {
  props: Props
  state: any

  constructor (props: Props) {
    super(props)

    this.state = {
      name: this.props.course.name,
      pending: false,
    }
  }

  course = () => ({
    ...this.props.course,
    name: this.state.name,
  })

  componentWillReceiveProps (props: Props) {
    if (props.error) {
      this.setState({ name: props.course.name, pending: false })
      setTimeout(() => {
        Alert.alert(ERROR_TITLE, props.error)
      }, 100)
      return
    }
    if (this.state.pending && !props.pending) {
      this.setState({ pending: false })
      this.props.navigator.dismissAllModals()
    }
  }

  updateColor = (color: string): void => {
    this.props.updateCourseColor(this.props.course.id, color)
  }

  dismiss = () => {
    if (this.props.course.name !== this.state.name) {
      this.setState({ pending: true })
      this.props.updateCourse(this.course(), this.props.course)
    } else {
      this.props.navigator.dismiss()
    }
  }

  render (): React.Element<*> {
    return (
      <Screen
        title={i18n('Customize Course')}
        subtitle={this.state.name}
        drawUnderNavBar={true}
        navBarStyle='light'
        navBarButtonColor={colors.link}
        navBarTranslucent={true}
        navBarTitleColor={colors.darkText}
        navBarSubtitleColor={this.props.color}
        rightBarButtons={[{
          title: i18n('Done'),
          style: 'done',
          testID: 'done_button',
          action: this.dismiss,
        }]}
      >
        <View style={{ flex: 1 }}>
          <ModalActivityIndicator text={i18n('Saving')} visible={this.state.pending} />
          <RefreshableScrollView
            style={{ flex: 1 }}
            refreshing={this.props.refreshing}
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
                  {i18n('Set this for the default color of the course. This won’t override a personal color setting.')}
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
              <View style={styles.separator} />
            </View>
          </RefreshableScrollView>
        </View>
      </Screen>
    )
  }
}

export let Refreshed: any = refresh(
  props => props.refreshCourses(),
  props => !props.course,
  props => Boolean(props.pending)
)(UserCoursePreferences)
const actions = {
  ...CoursesActions,
  ...CourseSettingsActions,
}
let connected = connect(stateToProps, actions)(Refreshed)
export default (connected: UserCoursePreferences)

const styles = StyleSheet.create({
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
  nicknameWrapper: {
    height: 54,
    paddingHorizontal: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  nicknameLabel: {
    fontWeight: '600',
  },
  nickname: {
    flex: 2,
    paddingLeft: 16,
    marginTop: 18,
    marginBottom: 17,
    height: 19,
    width: 167,
    color: '#2D3B45',
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
    color: '#8B969E',
  },
  colorButtonsWrapper: {
    padding: 8,
  },
  separator: {
    backgroundColor: '#C7CDD1',
    height: StyleSheet.hairlineWidth,
  },
})
