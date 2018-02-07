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
* Launching pad for navigation for a single course
* @flow
*/

import React from 'react'
import {
  StyleSheet,
  View,
} from 'react-native'

import i18n from 'format-message'
import Row from '../../../../common/components/rows/Row'

type Props = {
  tab: Tab,
  course: Course,
  courseColor: string,
  onPress: Function,
  selected: ?boolean,
}

export default class CourseDetailsHomeTab extends React.Component<Props, any> {

  onPress = () => {
    const tab = this.props.tab
    this.props.onPress(tab)
  }

  subtitle = (): ?string => {
    const { course } = this.props
    switch (course.default_view) {
      case 'assignments': return i18n('Assignments')
      case 'feed': return i18n('Recent Activity')
      case 'wiki': return i18n('Front Page')
      case 'modules': return i18n('Course Modules')
      case 'syllabus': return i18n('Syllabus')
      default: return null
    }
  }

  // Notice that CourseDetailsTab.js has a safe area around it, but this doesn't
  // There is a rendering issue that causes the containing scroll view to freak out.
  // We decided that because this tab is only shown in the student app and the student app doesn't support landscape, we don't
  // Need to have the safe area here, and that consequently fixed the layout issue.
  render () {
    const tab = this.props.tab
    return (<View style={style.container}>
              <View style={style.shadow}>
                <View style={style.innerContainer}>
                  <Row
                    title={tab.label}
                    titleStyles={style.title}
                    subtitle={this.subtitle()}
                    subtitleStyles={style.subtitle}
                    onPress={this.onPress}
                    disclosureIndicator
                    selected={this.props.selected}
                    testID={`courses-details.${tab.id}-cell`}
                  />
                </View>
              </View>
            </View>)
  }
}

const style = StyleSheet.create({
  container: {
    paddingTop: 16,
    paddingBottom: 8,
    paddingLeft: 16,
    paddingRight: 16,
  },
  shadow: {
    shadowColor: '#000',
    shadowRadius: 3,
    shadowOpacity: 0.3,
    shadowOffset: {
      width: 0,
      height: 1,
    },
    borderRadius: 4,
  },
  innerContainer: {
    borderColor: '#e3e3e3',
    borderWidth: StyleSheet.hairlineWidth,
    borderRadius: 4,
    overflow: 'hidden',
    flex: 1,
    backgroundColor: 'white',
  },
  title: {
    fontSize: 24,
    fontWeight: '400',
  },
  subtitle: {
    fontWeight: '600',
  },
})
