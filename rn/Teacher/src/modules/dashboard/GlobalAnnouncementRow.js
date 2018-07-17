//
// Copyright (C) 2017-present Instructure, Inc.
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

import i18n from 'format-message'
import React from 'react'
import {
  Image,
  LayoutAnimation,
  StyleSheet,
  TouchableHighlight,
  View,
} from 'react-native'
import images from '../../images'
import colors from '../../common/colors'
import {
  Text,
  SubTitle,
} from '../../common/text'
import { LinkButton } from '../../common/buttons'
import CanvasWebView from '../../common/components/CanvasWebView'
import DashboardContent from './DashboardContent'

const MESSAGE_STYLE = `
<style>
  html, body {
    color: ${colors.darkText};
    font-size: 16px;
  }
</style>
`

type Props = NavigationProps & {
  style?: any,
  notification: AccountNotification,
  onDismiss: (string) => any,
}

type State = {
  collapsed: boolean,
}

export default class GlobalAnnouncementRow extends React.Component<Props, State> {
  state = {
    collapsed: true,
  }

  content: TouchableHighlight | View | null

  toggle = () => {
    LayoutAnimation.easeInEaseOut()
    this.setState({ collapsed: !this.state.collapsed })
  }

  dismiss = () => {
    LayoutAnimation.easeInEaseOut()
    this.props.onDismiss(this.props.notification.id)
  }

  getColorFromIcon (icon: AccountNotificationIcon) {
    switch (icon) {
      case 'error':
        return colors.errorAnnouncementBg
      case 'warning':
        return colors.warningAnnouncementBg
      case 'information':
      default:
        return colors.primaryBrandColor
    }
  }

  getIconSource (icon: AccountNotificationIcon) {
    switch (icon) {
      case 'error':
      case 'warning':
        return images.dashboard.warning
      case 'question':
        return images.dashboard.help
      case 'calendar':
        return images.dashboard.calendar
      case 'information':
      default:
        return images.dashboard.info
    }
  }

  render () {
    const { style, notification: { subject, message, icon } } = this.props
    const { collapsed } = this.state
    const color = this.getColorFromIcon(icon)
    return (
      <DashboardContent
        style={style}
        contentStyle={[{ borderColor: color, borderWidth: 1 }]}
        hideShadow={true}
      >
        <View style={styles.rowContent}>
          <View style={[styles.iconContainer, { backgroundColor: color }]}>
            <Image source={this.getIconSource(icon)} style={styles.icon} />
          </View>
          <View style={styles.announcementDetails}>
            <TouchableHighlight
              accessibilityLabel={collapsed
                ? undefined
                : i18n('Hide content for {name}', { name: subject })
              }
              accessibilityTraits='button'
              hitSlop={{ top: 8, right: 16, bottom: 16, left: 56 }}
              onPress={this.toggle}
              underlayColor='transparent'
              testID='global-announcement-row.toggle'
            >
              <View>
                <Text style={styles.title}>{subject}</Text>
                { collapsed &&
                  <SubTitle>{i18n('Tap to view announcement')}</SubTitle>
                }
              </View>
            </TouchableHighlight>
            <CanvasWebView
              accessibilityElementsHidden={collapsed}
              automaticallySetHeight
              html={MESSAGE_STYLE + message}
              navigator={this.props.navigator}
              style={collapsed ? styles.collapsed : styles.expanded}
              isOpaque={false}
            />
            { !collapsed &&
              <LinkButton
                accessibilityLabel={i18n('Dismiss {name}', { name: subject })}
                style={styles.dismiss}
                onPress={this.dismiss}
                testID='global-announcement-row.dismiss'
              >
                {i18n('Dismiss')}
              </LinkButton>
            }
          </View>
        </View>
      </DashboardContent>
    )
  }
}

const styles = StyleSheet.create({
  icon: {
    marginTop: 14,
    tintColor: 'white',
  },
  rowContent: {
    flexDirection: 'row',
  },
  iconContainer: {
    width: 40,
    alignItems: 'center',
  },
  announcementDetails: {
    marginHorizontal: 12,
    marginVertical: 8,
    flex: 1,
  },
  title: {
    fontWeight: '600',
    marginRight: 32,
  },
  dismiss: {
    alignSelf: 'flex-end',
    paddingHorizontal: 4,
    paddingVertical: 2,
  },
  collapsed: {
    height: 0,
    overflow: 'hidden',
  },
  expanded: {
    overflow: 'hidden',
  },
})
