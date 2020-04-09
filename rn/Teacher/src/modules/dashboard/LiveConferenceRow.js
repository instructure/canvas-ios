//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import i18n from 'format-message'
import React from 'react'
import {
  Image,
  LayoutAnimation,
  TouchableHighlight,
  View,
} from 'react-native'
import icon from '../../images/inst-icons'
import { createStyleSheet } from '../../common/stylesheet'
import {
  Text,
  SubTitle,
} from '../../common/text'
import DashboardContent from './DashboardContent'

export default class LiveConferenceRow extends React.Component {
  dismiss = () => {
    LayoutAnimation.easeInEaseOut()
    this.props.onDismiss(this.props.conference.id)
  }

  navigate = () => {
    const { id, context_type, context_id } = this.props.conference
    this.props.navigator.show(`/${context_type.toLowerCase()}s/${context_id}/conferences/${id}/join`)
  }

  render () {
    const { style, conference: { id, title, contextName } } = this.props
    const name = contextName || title
    return (
      <DashboardContent
        style={style}
        contentStyle={styles.card}
        hideShadow={true}
      >
        <View style={styles.rowContent}>
          <View style={styles.iconContainer}>
            <Image source={icon('info', 'solid')} style={styles.icon} />
          </View>
          <TouchableHighlight
            accessibilityLabel={i18n('Conference {name} is in progress, tap to view details', { name })}
            accessibilityRole='button'
            style={styles.text}
            hitSlop={{ top: 0, right: 0, bottom: 0, left: 40 }}
            onPress={this.navigate}
            underlayColor='transparent'
            testID={`LiveConference.${id}.navigateButton`}
          >
            <View>
              <Text style={styles.title}>{i18n('Conference in progress')}</Text>
              <SubTitle>{name}</SubTitle>
            </View>
          </TouchableHighlight>
          <TouchableHighlight
            accessibilityLabel={i18n('Dismiss {name}', { name })}
            accessibilityRole='button'
            style={styles.dismiss}
            onPress={this.dismiss}
            underlayColor='transparent'
            testID={`LiveConference.${id}.dismissButton`}
          >
            <Image source={icon('x', 'solid')} style={styles.dismissIcon} />
          </TouchableHighlight>
        </View>
      </DashboardContent>
    )
  }
}

const styles = createStyleSheet(colors => ({
  card: {
    borderColor: colors.borderInfo,
    borderWidth: 1,
  },
  icon: {
    tintColor: colors.white,
    width: 24,
    height: 24,
  },
  rowContent: {
    flexDirection: 'row',
  },
  iconContainer: {
    width: 40,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.backgroundInfo,
  },
  text: {
    padding: 12,
    flex: 1,
  },
  title: {
    fontWeight: '600',
  },
  dismiss: {
    alignSelf: 'center',
    padding: 10,
  },
  dismissIcon: {
    tintColor: colors.textDark,
    width: 24,
    height: 24,
  },
}))
