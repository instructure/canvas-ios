// @flow

export type Course = {
  id: string,
  name: string,
  course_code: string,
  short_name?: string,
  image_download_url?: ?string,
  is_favorite?: boolean,
}

export type CustomColors = {
  custom_colors: {
    [string]: string,
  },
}

export type UpdateCustomColorResponse = {
  hexcode: string,
}

export type Favorite = {
  context_id: string,
  context_type: string,
}
