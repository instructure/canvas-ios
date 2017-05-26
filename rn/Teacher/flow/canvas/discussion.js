/* @flow */


export type DiscussionPermissions = { 
    attach: boolean,
    delete: boolean,
    reply:boolean,
    update: boolean,
}

export type Discussion = {
    id: string,
    assignment_id?: ?string,
    title: string,
    html_url: string,
    pinned: boolean,
    position: number,
    posted_at: string,
    published: boolean,
    read_state: null | 'read',
    sort_by_rating: boolean,
    subscribed: boolean,
    user_can_see_posts: boolean,
    user_name: string,
    unread_count: number,
    permissions: DiscussionPermissions[],
    message: string,
    assignment: ?Assignment,
}