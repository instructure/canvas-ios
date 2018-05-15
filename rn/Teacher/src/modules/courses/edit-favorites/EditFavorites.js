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

import React, { type Element, type ComponentType, Component } from 'react'
import {
  StyleSheet,
  SectionList,
  View,
} from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'
import App from '../../app'
import CourseFavorite from './components/CourseFavorite'
import FavoritesActions from './actions'
import CoursesActions from '../actions'
import GroupFavoriteActions from '../../groups/favorites/actions'
import mapStateToProps from './map-state-to-props'
import refresh from '../../../utils/refresh'
import Screen from '../../../routing/Screen'
import Navigator from '../../../routing/Navigator'
import colors from '../../../common/colors'
import { Heading1 } from '../../../common/text'
import { featureFlagEnabled } from '../../../common/feature-flags'

type SectionListSection = {
  sectionID: string,
  title?: string,
  seeAll?: () => void,
} & {
  data: $ReadOnlyArray<*>,
  key?: string,
  renderItem?: ?(info: {
    item: *,
    index: number,
    section: *,
    separators: {
      highlight: () => void,
      unhighlight: () => void,
      updateProps: (select: 'leading' | 'trailing', newProps: Object) => void,
    },
  }) => ?Element<any>,
  ItemSeparatorComponent?: ?ComponentType<any>,
  keyExtractor?: (item: *) => string,
}
// This is copy pasted out of `react-native/Libraries/Lists/SectionList.js` because the type
// is not exported in our RN version. It won't be exported until RN 0.52

type Props = {
  navigator: Navigator,
  courses: Array<Course>,
  groups: Array<Group>,
  courseFavorites: EntityRefs,
  groupFavorites: EntityRefs,
  toggleCourseFavorite: (courseID: string, favorite: boolean) => Promise<*>,
  updateGroupFavorites: (userID: string, favorites: string[]) => Promise<*>,
  pending: number,
} & RefreshProps

type State = {
}

const padding = 8

export class FavoritesList extends Component<Props, State> {
  renderCourse = ({ item }: { item: Course }) => {
    return (
      <CourseFavorite
        course={item}
        isFavorite={this.props.courseFavorites.includes(item.id)}
        onPress={this.props.toggleCourseFavorite}
      />
    )
  }

  renderGroup = ({ item }: { item: Group }) => {
    return (
      <CourseFavorite
        course={item}
        isFavorite={this.props.groupFavorites.includes(item.id)}
        onPress={this._onToggleFavoriteGroup}
      />
    )
  }

  renderHeader = ({ section }: { section: SectionListSection }) => {
    return (
      <View
        key={section.sectionID}
        accessibitilityTraits='heading'
        style={[{ padding }, styles.header]}
      >
        <Heading1 testID={section.sectionID + '.heading-lbl'}>
          {section.title}
        </Heading1>
      </View>
    )
  }

  loadSections = () => {
    let sections = []

    // Courses
    if (this.props.courses.length > 0) {
      sections.push({
        sectionID: 'editFavorites.courses',
        title: i18n('Courses'),
        data: this.props.courses,
        renderItem: this.renderCourse,
        keyExtractor: ({ id }: Course) => id,
      })
    }
    // Groups
    if (featureFlagEnabled('favoriteGroups')) {
      if (App.current().appId === 'student' &&
        this.props.groups &&
        this.props.groups.length > 0) {
        sections.push({
          sectionID: 'editFavorites.groups',
          title: i18n('Groups'),
          data: this.props.groups,
          renderItem: this.renderGroup,
          keyExtractor: ({ id }: Group) => id,
        })
      }
    }
    return sections
  }

  render () {
    const sections = this.loadSections()

    return (
      <Screen
        navBarTitleColor={colors.darkText}
        navBarButtonColor={colors.link}
        title={i18n('Edit Courses')}
        customPageViewPath={'/courses'}
      >
        <SectionList
          refreshing={this.props.refreshing}
          onRefresh={this.props.refresh}
          stickySectionHeadersEnabled={false}
          renderSectionHeader={this.renderHeader}
          sections={sections}
          renderItem={() => {}}
        // this prop is only necessary because renderItem is not listed as an optional prop
        // https://github.com/facebook/react-native/pull/17262
        />
      </Screen>
    )
  }

  _onToggleFavoriteGroup = (contextID: string, favorited: boolean): Promise<any> => {
    const index = this.props.groupFavorites.indexOf(contextID)
    let favs = [...this.props.groupFavorites]
    if (index > -1) {
      //  remove
      favs.splice(index, 1)
    } else {
      //  add
      favs.push(contextID)
    }
    return this.props.updateGroupFavorites('self', favs)
  }
}

export let Refreshed = refresh(
  props => props.refreshCourses(),
  props => props.courses.length === 0,
  props => Boolean(props.pending)
)(FavoritesList)
let Connected = connect(mapStateToProps, { ...CoursesActions, ...FavoritesActions, ...GroupFavoriteActions })(Refreshed)
export default (Connected: FavoritesList)

const styles = StyleSheet.create({
  listStyle: {
    backgroundColor: '#fff',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    paddingBottom: 0,
    paddingTop: 16,
  },
  gridish: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    padding,
  },
})
