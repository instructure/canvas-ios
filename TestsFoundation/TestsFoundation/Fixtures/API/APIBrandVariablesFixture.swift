//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
@testable import Core

extension APIBrandVariables: Fixture {
    public static var template: Template {
        // https://canvas.instructure.com/api/v1/brand_variables
        return [
            "ic-brand-primary-darkened-5": "#0087D7",
            "ic-brand-primary-darkened-10": "#0080CC",
            "ic-brand-primary-darkened-15": "#0079C1",
            "ic-brand-primary-lightened-5": "#0C93E3",
            "ic-brand-primary-lightened-10": "#1999E4",
            "ic-brand-primary-lightened-15": "#269EE6",
            "ic-brand-button--primary-bgd-darkened-5": "#0087D7",
            "ic-brand-button--primary-bgd-darkened-15": "#0079C1",
            "ic-brand-button--secondary-bgd-darkened-5": "#2B3942",
            "ic-brand-button--secondary-bgd-darkened-15":"#27333B",
            "ic-brand-font-color-dark-lightened-15": "#4C5860",
            "ic-brand-font-color-dark-lightened-30": "#6C757C",
            "ic-link-color-darkened-10": "#0080CC",
            "ic-link-color-lightened-10": "#1999E4",
            "ic-brand-primary": "#008EE2",
            "ic-brand-font-color-dark": "#2D3B45",
            "ic-link-color": "#008EE2",
            "ic-brand-button--primary-bgd": "#008EE2",
            "ic-brand-button--primary-text": "#ffffff",
            "ic-brand-button--secondary-bgd": "#2D3B45",
            "ic-brand-button--secondary-text": "#ffffff",
            "ic-brand-global-nav-bgd": "#394B58",
            "ic-brand-global-nav-ic-icon-svg-fill": "#ffffff",
            "ic-brand-global-nav-ic-icon-svg-fill--active": "#008EE2",
            "ic-brand-global-nav-menu-item__text-color": "#ffffff",
            "ic-brand-global-nav-menu-item__text-color--active": "#008EE2",
            "ic-brand-global-nav-avatar-border": "#ffffff",
            "ic-brand-global-nav-menu-item__badge-bgd": "#008EE2",
            "ic-brand-global-nav-menu-item__badge-text": "#ffffff",
            "ic-brand-global-nav-logo-bgd": "#394B58",
            "ic-brand-header-image": "https://instructure-uploads.s3.amazonaws.com/account_70000000000010/attachments/64473710/canvas_logomark_only2x.png",
            "ic-brand-watermark": "",
            "ic-brand-watermark-opacity": "1",
            "ic-brand-favicon": "https://du11hjcvx0uqb.cloudfront.net/dist/images/favicon-e10d657a73.ico",
            "ic-brand-apple-touch-icon": "https://du11hjcvx0uqb.cloudfront.net/dist/images/apple-touch-icon-585e5d997d.png",
            "ic-brand-msapplication-tile-color": "#008EE2",
            "ic-brand-msapplication-tile-square": "https://du11hjcvx0uqb.cloudfront.net/dist/images/windows-tile-f2359ad914.png",
            "ic-brand-msapplication-tile-wide": "https://du11hjcvx0uqb.cloudfront.net/dist/images/windows-tile-wide-52212226d6.png",
            "ic-brand-right-sidebar-logo": "",
            "ic-brand-Login-body-bgd-color": "#394B58",
            "ic-brand-Login-body-bgd-image": "",
            "ic-brand-Login-body-bgd-shadow-color": "#2D3B45",
            "ic-brand-Login-logo": "https://du11hjcvx0uqb.cloudfront.net/dist/images/login/canvas-logo-a66b946d8d.svg",
            "ic-brand-Login-Content-bgd-color": "none",
            "ic-brand-Login-Content-border-color": "none",
            "ic-brand-Login-Content-inner-bgd": "none",
            "ic-brand-Login-Content-inner-border": "none",
            "ic-brand-Login-Content-inner-body-bgd": "none",
            "ic-brand-Login-Content-inner-body-border": "none",
            "ic-brand-Login-Content-label-text-color": "#ffffff",
            "ic-brand-Login-Content-password-text-color": "#ffffff",
            "ic-brand-Login-footer-link-color": "#ffffff",
            "ic-brand-Login-footer-link-color-hover": "#ffffff",
            "ic-brand-Login-instructure-logo": "#ffffff",
        ]
    }
}
