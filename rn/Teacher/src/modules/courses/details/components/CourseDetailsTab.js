/**
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component, Element } from 'react'
import {
  View,
  Text,
  Image,
  TouchableHighlight,
  StyleSheet,
} from 'react-native'

import Images from '../../../../images'
import DisclosureIndicator from '../../../../common/components/DisclosureIndicator'

type Props = {
  tab: Tab,
  courseColor: string,
  onPress: Function,
}

export default class CourseDetails extends Component<any, Props, any> {

  imageForTab (tab: Tab): ?any {
    switch (tab.id) {
      case 'announcements':
        return Images.course.announcements
      case 'assignments':
        return Images.course.assignments
      case 'discussions':
        return Images.course.discussions
      case 'pages':
        return Images.course.pages
      case 'people':
        return Images.course.people
      case 'quiz':
        return Images.course.quiz
      case 'syllabus':
        return Images.course.syllabus
      case 'files':
        return Images.course.files
      default:
        return Images.course.files
    }
  }

  onPress = () => {
    const tab = this.props.tab
    this.props.onPress(tab)
  }

  render (): Element<View> {
    const tab = this.props.tab
    return (
        <View style={styles.tab} key={tab.id}>
          <TouchableHighlight style={styles.tabTouchableHighlight} onPress={this.onPress}>
            <View style={styles.tabInnerContainer}>
              <Image style={[styles.tabImage, { tintColor: this.props.courseColor }]} source={this.imageForTab(tab)} />
              <Text style={styles.tabLabel}>{tab.label}</Text>
              <View style={styles.disclosureIndicatorContainer}>
                <DisclosureIndicator />
              </View>
            </View>
          </TouchableHighlight>
        </View>
    )
  }
}

const styles = StyleSheet.create({
  tab: {
    flex: 1,
    height: 44,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
  },
  tabTouchableHighlight: {
    flex: 1,
  },
  tabLabel: {
    fontWeight: 'bold',
  },
  tabImage: {
    height: 20,
    width: 21,
    resizeMode: 'contain',
    marginRight: 6,
  },
  tabInnerContainer: {
    flex: 1,
    padding: 8,
    backgroundColor: 'white',
    alignItems: 'center',
    flexDirection: 'row',
  },
  disclosureIndicatorContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
})
