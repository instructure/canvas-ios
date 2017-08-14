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
