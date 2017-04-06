/**
 * Created by bkraus on 3/8/17.
 * @flow
 */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  Text,
  TextInput,
  TouchableHighlight,
  PickerIOS,
  Image,
  LayoutAnimation,
  Alert,
} from 'react-native'

import i18n from 'format-message'
import Colors from '../../../common/colors'
import { mapStateToProps } from './map-state-to-props'
import CourseSettingsActions from './actions'
import ModalActivityIndicator from '../../../common/components/ModalActivityIndicator'
import { ERROR_TITLE } from '../../../redux/middleware/error-handler'
import { Navigation } from 'react-native-navigation'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'

var PickerItemIOS = PickerIOS.Item

type Props = {
  navigator: ReactNavigator,
  course: Course,
  color: string,
  updateCourse: (Course, Course) => Course,
  pending: number,
  error: ?string,
}

const DISPLAY_NAMES = new Map([
  ['feed', i18n({
    default: 'Course Activity Stream',
    description: 'Name of course default view being the activity stream when navigating into a course',
  })],
  ['wiki', i18n({
    default: 'Pages Front Page',
    description: 'Name of course default view being the font page when navigating into a course',
  })],
  ['modules', i18n({
    default: 'Course Modules',
    description: 'Name of course default view being the course modules when navigating into a course',
  })],
  ['assignments', i18n({
    default: 'Assignments List',
    description: 'Name of course default view being the assignments list when navigating into a course',
  })],
  ['syllabus', i18n({
    default: 'Syllabus',
    description: 'Name of course default view being the syllabus when navigating into a course',
  })],
])

export class CourseSettings extends Component<any, Props, any> {

  static navigatorStyle = {
    drawUnderNavBar: true,
    navBarTranslucent: true,
    navBarTextColor: Colors.darkText,
    navBarHidden: false,
    modalPresentationStyle: 'formSheet',
  }

  static navigatorButtons = {
    rightButtons: [{
      id: 'done',
      title: i18n('Done'),
    }],
    leftButtons: [{
      id: 'cancel',
      title: i18n('Cancel'),
    }],
  }

  constructor (props: Props) {
    super(props)

    this.props.navigator.setTitle({
      title: i18n({
        default: 'Course Settings',
        description: 'Screen title for the course settings screen',
      }),
    })

    this.props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)

    this.state = {
      name: this.props.course.name,
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
        Alert.alert(ERROR_TITLE, props.error)
      }, 100)
    }
    this.state.pending && !props.pending && !props.error && Navigation.dismissAllModals()
  }

  onNavigatorEvent = (event: NavigatorEvent) => {
    switch (event.type) {
      case 'NavBarButtonPress':
        switch (event.id) {
          case 'done':
            this.setState({ pending: true })
            this.props.updateCourse(this.course(), this.props.course)
            break
          case 'cancel':
            this.props.navigator.dismissModal()
            break
        }
        break
    }
  }

  _togglePicker = () => {
    let animation = LayoutAnimation.create(250, LayoutAnimation.Types.linear, LayoutAnimation.Properties.opacity)
    LayoutAnimation.configureNext(animation)
    this.setState({ showingPicker: !this.state.showingPicker })
  }

  render (): React.Element<*> {
    return (
      <View style={{ flex: 1 }}>
        <ModalActivityIndicator text={i18n('Saving')} visible={this.state.pending} />
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
              <Text style={styles.primaryText}>
                {i18n({
                  default: 'Name',
                  description: 'Label for prompt to select course name',
                })}
              </Text>
              <TextInput
                value={this.state.name}
                style={styles.actionableText}
                onChangeText={(text) => this.setState({ name: text })}
                testID='nameInput'
              />
            </View>
          </View>
          <View style={styles.separator}/>
          <TouchableHighlight
            underlayColor="#eee"
            onPress={this._togglePicker}
            testID='courses.settings.toggle-home-picker'
          >
            <View style={styles.row}>
                <View style={styles.rowContent}>
                  <Text style={styles.primaryText}>
                    {i18n({
                      default: `Set 'Home' to...`,
                      description: 'Label for prompt to select the course landing page',
                    })}
                  </Text>
                  <Text
                    style={styles.actionableText}
                    testID='homePageLabel'>
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
              testID='homePicker'>
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
    color: Colors.darkText,
    fontFamily: '.SFUIDisplay-semibold',
    fontSize: 16,
    lineHeight: 54,
  },
  actionableText: {
    flex: 3,
    color: Colors.link,
    fontFamily: '.SFUIDisplay-medium',
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
