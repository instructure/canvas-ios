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
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component } from 'react'
import {
  View,
  Animated,
  RefreshControl,
  DeviceInfo,
} from 'react-native'

import TabRow from './TabRow'
import HomeTabRow from './HomeTabRow'
import OnLayout from 'react-native-on-layout'
import { isStudent } from '../app'
import { createStyleSheet } from '../../common/stylesheet'

type TabsListProps = {
  tabs: Array<Tab>,
  title: string,
  subtitle: string,
  color: string,
  showColorOverlay: boolean,
  imageURL: ?string,
  defaultView: ?string,
  onSelectTab: (Tab) => void,
  refreshing: boolean,
  onRefresh: Function,
  attendanceTabID: ?string,
  selectedTabId: ?string,
  windowTraits: any,
}

export default class TabsList extends Component<TabsListProps, any> {
  animatedValue: Animated.Value = new Animated.Value(-235)
  animate = Animated.event(
    [{ nativeEvent: { contentOffset: { y: this.animatedValue } } }],
  )

  onScroll = (event: any) => {
    const offsetY = event.nativeEvent.contentOffset.y
    // Random bug/issue with rn or ios
    // Sometimes this would randomly be reported as 0, which is impossible based on our content inset/offsets
    if (offsetY !== 0) {
      this.animate(event)
    }
  }

  renderTab = (tab: Tab) => {
    const props = {
      key: tab.id,
      tab,
      color: this.props.color,
      onPress: this.props.onSelectTab,
      attendanceTabID: this.props.attendanceTabID,
      testID: `courses-details.tab.${tab.id}`,
      selected: this.props.selectedTabId === tab.id,
      defaultView: this.props.defaultView,
      loadingStudentView: this.props.loadingStudentView,
    }
    if (isStudent() && tab.id === 'home') {
      return <HomeTabRow {...props} />
    }

    return <TabRow {...props} />
  }

  render () {
    const { color, imageURL, title, subtitle } = this.props

    let compactMode = this.props.windowTraits.horizontal === 'compact'
    let bothCompact = this.props.windowTraits.horizontal === 'compact' && this.props.windowTraits.vertical === 'compact'
    let navbarHeight = bothCompact ? 52 : 64
    // when there is no color overlay, the navbar is visible and as such we don't want
    // to add extra height to the scroll collapse for a fake navbar
    if (!this.props.showColorOverlay) {
      navbarHeight = 0
    }
    let headerHeight = bothCompact ? 150 : 235
    let headerBottomContainerMarginTop = bothCompact ? 8 : 44
    let headerBottomContainerHorizontalMargin = bothCompact ? 44 : 0

    // David made me do it
    if (DeviceInfo.isIPhoneX_deprecated) {
      navbarHeight = bothCompact ? 32 : 88
    }

    let fadeOut = this.animatedValue.interpolate({
      inputRange: [-headerHeight, -navbarHeight],
      outputRange: [1, 0],
    })
    let inOffsets = {}
    if (compactMode) {
      inOffsets = {
        contentInset: { top: headerHeight },
        contentOffset: { y: -headerHeight },
      }
    }

    return (
      <View style={styles.container}>
        <OnLayout style={styles.tabContainer}>
          {({ height }) => (
            <Animated.ScrollView
              scrollEventThrottle={1}
              contentInsetAdjustmentBehavior='never'
              automaticallyAdjustContentInsets={false}
              onScroll={this.onScroll}
              refreshControl={
                <RefreshControl
                  refreshing={false /* this.props.refreshing MBL-13034 */}
                  onRefresh={this.props.onRefresh}
                  style={{ position: 'absolute', top: headerHeight }}
                />
              }
              style={{ flex: 1 }}
              {...inOffsets}
            >
              <View style={{ minHeight: height - navbarHeight }}>
                {this.props.tabs.map(this.renderTab)}
              </View>
            </Animated.ScrollView>
          )}
        </OnLayout>

        {compactMode &&
          <Animated.View
            style={[styles.header, {
              height: this.animatedValue.interpolate({
                inputRange: [-headerHeight, -navbarHeight],
                outputRange: [headerHeight, navbarHeight],
                extrapolate: 'clamp',
              }),
            }]}
            pointerEvents='none'
          >
            <OnLayout style={styles.headerImageContainer}>
              {({ width }) => (
                <View style={styles.headerImageContainer}>
                  {Boolean(imageURL) &&
                      <Animated.Image
                        source={{ uri: imageURL }}
                        style={[styles.headerImage, {
                          width,
                          height: this.animatedValue.interpolate({
                            inputRange: [-headerHeight, -navbarHeight],
                            outputRange: [headerHeight, navbarHeight],
                            extrapolate: 'clamp',
                          }),
                          opacity: fadeOut,
                        }]}
                        resizeMode='cover'
                      />
                  }
                  {this.props.showColorOverlay &&
                    <Animated.View
                      style={[styles.headerImageOverlay, {
                        backgroundColor: color,
                        opacity: imageURL
                          ? this.animatedValue.interpolate({
                            inputRange: [-headerHeight, -navbarHeight],
                            outputRange: [0.8, 1],
                            extrapolate: 'clamp',
                          })
                          : 1,
                      }]}
                    />
                  }
                </View>
              )}
            </OnLayout>
            {this.props.showColorOverlay &&
              <View style={[styles.headerBottomContainer, {
                marginTop: headerBottomContainerMarginTop,
                marginHorizontal: headerBottomContainerHorizontalMargin,
              }]} >
                <Animated.Text
                  style={[styles.headerTitle, {
                    opacity: fadeOut,
                  }]}
                  testID='course-details.title-lbl'
                  numberOfLines={3}
                >
                  { title }
                </Animated.Text>
                <Animated.Text
                  style={[styles.headerSubtitle, {
                    opacity: fadeOut,
                  }]}
                  testID='course-details.subtitle-lbl'
                >
                  { subtitle }
                </Animated.Text>
              </View>
            }
          </Animated.View>
        }
      </View>
    )
  }
}

const styles = createStyleSheet(colors => ({
  container: {
    flex: 1,
  },
  header: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 10,
    paddingTop: 20,
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    overflow: 'hidden',
  },
  headerTitle: {
    backgroundColor: 'transparent',
    color: colors.white,
    fontWeight: '600',
    fontSize: 24,
    textAlign: 'center',
    marginBottom: 3,
  },
  headerSubtitle: {
    color: colors.white,
    opacity: 0.9,
    backgroundColor: 'transparent',
    fontWeight: '600',
  },
  headerImageContainer: {
    position: 'absolute',
    right: 0,
    left: 0,
    top: 0,
    bottom: 0,
  },
  headerImage: {
    position: 'absolute',
  },
  headerImageOverlay: {
    position: 'absolute',
    opacity: 0.75,
    right: 0,
    left: 0,
    top: 0,
    bottom: 0,
  },
  headerBottomContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  settingsButton: {
    width: 24,
  },
  tabContainer: {
    flex: 1,
    justifyContent: 'flex-start',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
}))
