// @flow

export type Page = {
  url: string,
  title: string,
  created_at: string,
  updated_at: string,
  hide_from_students: boolean,
  editing_roles: string, // comma separated eg: "students,teachers"
  body: string,
  published: boolean,
  front_page: boolean,
}
