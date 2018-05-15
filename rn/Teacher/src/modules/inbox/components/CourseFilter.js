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

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  ActionSheetIOS,
  ActivityIndicator,
} from 'react-native'

import { Heading1 } from '../../../common/text'
import { LinkButton } from '../../../common/buttons'
import i18n from 'format-message'

export type CourseFilterProps = {
  courses: Array<Course>,
  selectedCourse?: ?Course | 'all',
  onClearFilter: () => void,
  onSelectFilter: (string) => void,
}

export default class CourseFilter extends Component<CourseFilterProps, any> {
  chooseFilter = () => {
    const options = this.props.courses.map((course) => course.name)
    options.push(i18n('Cancel'))
    ActionSheetIOS.showActionSheetWithOptions({
      options,
      cancelButtonIndex: options.length - 1,
      title: i18n('Filter by:'),
    }, this.updateFilter)
  }

  updateFilter = (index: number) => {
    if (index !== this.props.courses.length) {
      const courseId = this.props.courses[index].id
      this.props.onSelectFilter(courseId)
    }
  }

  clearFilter = () => {
    this.props.onClearFilter()
  }

  render () {
    let title = i18n('All Courses')
    if (this.props.selectedCourse !== 'all') {
      let course = this.props.courses.find((c) => c.id === this.props.selectedCourse)
      if (course) title = course.name
    }

    return (<View style={styles.headerWrapper}>
      <View style={styles.header}>
        <Heading1
          style={styles.headerTitle}
          numberOfLines={1}
        >
          { title }
        </Heading1>
        { this.renderFilterButton() }
      </View>
    </View>)
  }

  renderFilterButton = () => {
    if (!this.props.courses || this.props.courses.length === 0) {
      return <ActivityIndicator />
    }
    let title = i18n('Filter')
    let accessibilityLabel = i18n('Filter Inbox')
    let onPress = this.chooseFilter

    if (this.props.selectedCourse !== 'all') {
      title = i18n('Clear Filter')
      accessibilityLabel = i18n('Clear Filter Inbox')
      onPress = this.clearFilter
    }

    return (<LinkButton
      testID='inbox.filterByCourse'
      onPress={onPress}
      style={styles.filterButton}
      accessibilityLabel={ accessibilityLabel }
    >
      { title }
    </LinkButton>)
  }
}

const styles = StyleSheet.create({
  headerWrapper: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
    paddingTop: 16,
    paddingBottom: 8,
    paddingHorizontal: 16,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
  },
  headerTitle: {
    flex: 1,
    fontSize: 20,
    fontWeight: '600',
    color: '#2d3b44',
  },
  filterButton: {
    marginBottom: 1,
    marginLeft: global.style.defaultPadding / 2,
    flexShrink: 0,
  },
})
