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

import React, { type Element, type ComponentType, Component } from 'react'
import { SectionList, View, Text, SafeAreaView } from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'
import App from '../../app'
import CourseFavorite from './components/CourseFavorite'
import FavoritesActions from './actions'
import DashboardActions from '../../dashboard/actions'
import CoursesActions from '../actions'
import GroupFavoriteActions from '../../groups/favorites/actions'
import mapStateToProps from './map-state-to-props'
import Screen from '../../../routing/Screen'
import Navigator from '../../../routing/Navigator'
import { createStyleSheet } from '../../../common/stylesheet'
import SectionHeader from '../../../common/components/rows/SectionHeader'
import ExperimentalFeature from '../../../common/ExperimentalFeature'

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
  getDashboardCards: () => void,
  pending: number,
} & RefreshProps

export class FavoritesList extends Component<Props> {
  UNSAFE_componentWillReceiveProps (nextProps: Props) {
    if (nextProps.pending === 0 && this.props.pending > 0) {
      this.props.getDashboardCards()
    }
  }

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
      <SectionHeader
        key={section.key}
        testID={section.sectionID + '.heading-lbl'}
        title={section.title || ''}
        top={section.sectionID === 'editFavorites.courses'}
      />
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
    if (ExperimentalFeature.favoriteGroups.isEnabled) {
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
        title={i18n('Edit Dashboard')}
        customPageViewPath='/courses'
      >
        <SafeAreaView style={styles.container}>
          <View style={styles.header}>
            <Text style={styles.hearderText}>{i18n('Select which courses you would like to see on the Dashboard.')}</Text>
          </View>
          <SectionList
            style={styles.list}
            refreshing={this.props.refreshing}
            onRefresh={this.props.refresh}
            stickySectionHeadersEnabled={false}
            renderSectionHeader={this.renderHeader}
            sections={sections}
            renderItem={() => {}}
            // this prop is only necessary because renderItem is not listed as an optional prop
            // https://github.com/facebook/react-native/pull/17262
          />
        </SafeAreaView>
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

let Connected = connect(
  mapStateToProps,
  {
    ...CoursesActions,
    ...FavoritesActions,
    ...GroupFavoriteActions,
    ...DashboardActions,
  }
)(FavoritesList)
export default (Connected: FavoritesList)

const styles = createStyleSheet(colors => ({
  container: {
    flex: 1,
    flexDirection: 'column',
    backgroundColor: colors.backgroundLightest,
  },
  header: {
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  hearderText: {
    fontWeight: '500',
  },
  list: {
    flex: 1,
  },
}))
