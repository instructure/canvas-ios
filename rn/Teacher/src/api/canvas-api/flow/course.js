// @flow

export type Course = {
  id: number,
  name: string,
  course_code: string,
  short_name: string,
  color?: ?string,
  image_download_url?: ?string,
  is_favorite?: boolean,
}

export type CustomColors = {
  custom_colors: {
    [string]: string,
  },
}

