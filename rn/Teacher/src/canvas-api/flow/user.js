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

export type CustomColorsResponse = {
  custom_colors: any,
}

export type User = {
  id: string,
  name: string,
  short_name: string,
  sortable_name: string,
  bio?: string,
  avatar_url: string,
  primary_email: string,
}

export type UserDisplay = {
  id: string,
  display_name: string,
  short_name: string,
  avatar_url: string,
  avatar_image_url: string,
  html_url: string,
}

export type CreateUser = {
  user: {
    name: string,
    short_name?: string,
    sortable_name?: string,
    time_zone?: string,
    locale?: string,
    birthdate?: Date,
    terms_of_use?: boolean,
    skip_registration?: boolean,
  },
  pseudonym: {
    unique_id: string,
    password: string,
    sis_user_id?: string,
    integration_id?: string,
    send_confirmation?: boolean,
    force_self_registration?: boolean,
    authentication_provider_id?: string,
  },
  communication_channel?: {
    communication_channel_type?: string,
    communication_channel_address?: string,
    communication_channel_confirmation_url?: boolean,
    communication_channel_skip_confirmation?: boolean,
  },
}
