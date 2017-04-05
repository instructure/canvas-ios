// @flow

export type CustomColorsResponse = {
  custom_colors: any,
}

export type User = {
  +id: string,
  +name: string,
  +short_name: string,
  +sortable_name: string,
  +bio?: string,
  +avatar_url: string,
}
