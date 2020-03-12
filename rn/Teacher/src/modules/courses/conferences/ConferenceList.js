//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

/**
 * @flow
 */

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  FlatList,
} from 'react-native'
import i18n from 'format-message'
import Screen from '../../../routing/Screen'
import ListEmptyComponent from '@common/components/ListEmptyComponent'
import RowSeparator from '../../../common/components/rows/RowSeparator'
import Row from '../../../common/components/rows/Row'
import { fetchPropsFor, ConferenceModel } from '../../../canvas-api/model-api'
import { getSession } from '../../../canvas-api/index'
import { alertError } from '../../../redux/middleware/error-handler'

type Props = {
  course: Course,
  navigator: Navigator,
  color: string,
  conferences: ?Conference[],
  isLoading: boolean,
  loadError: ?Error,
  refresh: () => void,
}
type State = {conferences: Conference[], pending: boolean}

export class ConferenceList extends Component<Props, State> {
  componentWillReceiveProps ({ loadError }: Props) {
    if (loadError && loadError !== this.props.loadError) alertError(loadError)
  }

  render () {
    const { course, color, isLoading, conferences, refresh } = this.props
    let subtitle = course.name || ''
    return (
      <Screen
        title={i18n('Conferences')}
        subtitle={subtitle}
        navBarColor={color}
        navBarStyle='context'
      >
        <View style={style.container}>
          <FlatList
            ListEmptyComponent={ <ListEmptyComponent title={i18n('There are no conferences to display.')} /> }
            data={conferences}
            refreshing={isLoading}
            renderItem={this.renderRow}
            onRefresh={refresh}
            keyExtractor={ConferenceModel.keyExtractor}
            testID='conferences.list.list'
            ItemSeparatorComponent={RowSeparator}
          />
        </View>
      </Screen>
    )
  }

  renderRow = ({ item, index }: { item: Conference, index: number }) => {
    return (
      <Row
        title={item.title}
        subtitle={item.description}
        image={{ uri: 'conferences' }}
        imageTint={this.props.color}
        disclosureIndicator
        border='bottom'
        onPress={() => { this.showConference(item) } }
        testID={`conferences-list.conference.row-${item.id}`}
      />
    )
  }

  showConference = (conference: Conference) => {
    let url = conference.join_url
    if (!url) {
      let session = getSession()
      url = `${session.baseURL}courses/${this.props.course.id}/conferences/${conference.id}/join`
    }
    this.props.navigator.show(url)
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
  },
})

export default fetchPropsFor(ConferenceList, ({ course }, api) => ({
  conferences: api.getConferences(course.id),
}))
