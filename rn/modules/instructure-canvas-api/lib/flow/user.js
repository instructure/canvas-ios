//
// Copyright (C) 2016-present Instructure, Inc.
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
  }
}
