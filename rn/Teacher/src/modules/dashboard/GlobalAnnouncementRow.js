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

import i18n from 'format-message'
import React from 'react'
import {
  AccessibilityInfo,
  findNodeHandle,
  Image,
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

  toggle = () => this.setState({
    collapsed: !this.state.collapsed,
  }, () => {
    const handle = findNodeHandle(this.content)
    if (handle) {
      AccessibilityInfo.setAccessibilityFocus(handle)
    }
  })

  dismiss = () => {
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
        {collapsed ? (
          <TouchableHighlight
            accessibilityTraits='button'
            onPress={this.toggle}
            underlayColor='transparent'
            testID='global-announcement-row.expand'
            ref={(node) => { this.content = node }}
          >
            <View style={styles.rowContent}>
              <View style={[styles.iconContainer, { backgroundColor: color }]}>
                <Image source={this.getIconSource(icon)} style={styles.icon} />
              </View>
              <View style={styles.announcementDetails}>
                <Text style={styles.title}>{subject}</Text>
                <SubTitle>{i18n('Tap to view announcement')}</SubTitle>
              </View>
            </View>
          </TouchableHighlight>
        ) : (
          <View style={styles.rowContent}>
            <View style={[styles.iconContainer, { backgroundColor: color }]}>
              <Image source={this.getIconSource(icon)} style={styles.icon} />
            </View>
            <View style={styles.announcementDetails}>
              <View ref={(node) => { this.content = node }}>
                <Text style={styles.openTitle}>{subject}</Text>
              </View>
              <CanvasWebView
                automaticallySetHeight
                style={styles.message}
                html={MESSAGE_STYLE + message}
                navigator={this.props.navigator}
              />
              <LinkButton
                accessibilityLabel={i18n('Dismiss {name}', { name: subject })}
                style={styles.dismiss}
                textStyle={styles.dismissText}
                onPress={this.dismiss}
                testID='global-announcement-row.dismiss'
              >
                {i18n('Dismiss')}
              </LinkButton>
            </View>
          </View>
        )}
        <TouchableHighlight
          accessibilityTraits='button'
          accessibilityLabel={collapsed
            ? i18n('Dismiss {name}', { name: subject })
            : i18n('Hide content for {name}', { name: subject })
          }
          onPress={collapsed ? this.dismiss : this.toggle}
          underlayColor='transparent'
          style={styles.action}
          testID='global-announcement-row.button'
        >
          {collapsed
            ? <Image source={images.x} style={styles.dismissIcon} />
            : <Image source={images.chevronUp} style={styles.collapseIcon} />
          }
        </TouchableHighlight>
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
  openTitle: {
    fontWeight: '600',
    marginRight: 32,
    marginTop: 8,
  },
  message: {
    marginVertical: 8,
  },
  action: {
    position: 'absolute',
    right: 0,
    top: 0,
    padding: 12,
  },
  dismiss: {
    alignSelf: 'flex-end',
    paddingHorizontal: 4,
    paddingVertical: 2,
  },
  dismissText: {
    fontSize: 16,
  },
  dismissIcon: {
    width: 16,
    tintColor: colors.grey4,
  },
  collapseIcon: {
    marginVertical: 3,
    width: 16,
    tintColor: colors.grey4,
  },
})
