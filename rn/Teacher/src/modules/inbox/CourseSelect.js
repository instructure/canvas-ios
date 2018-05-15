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
  SectionList,
} from 'react-native'
import { connect } from 'react-redux'
import refresh from '../../utils/refresh'
import Screen from '../../routing/Screen'
import i18n from 'format-message'
import CourseActions from '../courses/actions'
import GroupActions from '../groups/actions'
import Row from '../../common/components/rows/Row'
import SectionHeader from '../../common/components/rows/SectionHeader'
import App from '../app'

type CourseSelectSection = {
  key: number,
  title: string,
  data: Course[],
}

type CourseSelectDataProps = {
  sections: CourseSelectSection[],
  pending: boolean,
}

type CourseActionProps = {
  refreshCourses: () => void,
}

type CourseSelectProps = {
  navigator: Navigator,
  onSelect: (course: Course) => void,
} & CourseSelectDataProps

export class CourseSelect extends PureComponent<CourseSelectProps> {
  onCourseSelect = (course: Course) => {
    this.props.onSelect(course)
  }

  renderItem = ({ item, index }: { item: Course, index: number }) => {
    let border = 'bottom'
    if (index === 0) {
      border = 'both'
    }
    return <Row title={item.name}
      border={border}
      onPress={this.onCourseSelect}
      identifier={item}
      testID={`inbox.course-select.course-${item.id}`} />
  }

  renderSectionHeader = ({ section }: any) => {
    return <SectionHeader
      title={section.title}
      border={section.key === 0 ? 'top' : 'none'} />
  }

  keyExtractor (item: Course) {
    return item.id
  }

  render () {
    return (
      <Screen
        title={i18n('Select a Course')}
        drawUnderNavBar
      >
        <SectionList
          sections={this.props.sections}
          renderItem={this.renderItem}
          renderSectionHeader={this.renderSectionHeader}
          keyExtractor={this.keyExtractor}
        />
      </Screen>
    )
  }
}

export const shouldRefresh: Function = (props: CourseActionProps) => true
export const doRefresh: Function = (props: CourseActionProps) => {
  props.refreshCourses()
}
export const isRefreshing: Function = (props: CourseSelectDataProps) => props.pending

const Refreshed = refresh(
  doRefresh,
  shouldRefresh,
  isRefreshing,
)(CourseSelect)

export function mapStateToProps (state: AppState): CourseSelectDataProps {
  let courses = Object.keys(state.entities.courses)
    .map(id => state.entities.courses[id].course)
    .filter(App.current().filterCourse)
  let pending = !!state.favoriteCourses.pending

  const favoriteCourses = courses.filter((course) => course.is_favorite)
  const allOtherCourses = courses.filter((course) => !course.is_favorite)

  const sections: CourseSelectSection[] = [
    {
      key: 0,
      title: i18n('Favorite Courses'),
      data: favoriteCourses,
    },
    {
      key: 1,
      title: i18n('Courses'),
      data: allOtherCourses,
    },
  ]

  return { sections, pending }
}

const Connected = connect(mapStateToProps, { ...CourseActions, ...GroupActions })(Refreshed)
export default (Connected: PureComponent<CourseSelectDataProps, any>)
