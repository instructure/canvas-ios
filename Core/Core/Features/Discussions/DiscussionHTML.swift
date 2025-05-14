//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import UIKit

public enum DiscussionHTML {
    // shortcuts to encode text for html
    static func t(_ text: String?) -> String { CoreWebView.htmlString(text) }
    static func s(_ text: String?) -> String { CoreWebView.jsString(text) }
    static func s(_ styles: Styles) -> String { "'\(styles)'" }

    // HTML string rendering for static content

    public static func string(for topic: DiscussionTopic) -> String {
        """
        <style>\(css)</style>
        \(entryHeader(author: topic.author, date: topic.postedAt, attachment: topic.attachments?.first, isTopic: true))
        \(topic.message ?? "")
        """
    }

    static func string(for entry: DiscussionEntry) -> String {
        """
        <style>\(css)</style>
        <div class="\(Styles.entry)">
            \(entryHeader(author: entry.author, date: entry.updatedAt, attachment: entry.isRemoved ? nil : entry.attachment, isTopic: true))
            \(message(for: entry))
        </div>
        """
    }

    static func entryHeader(author: DiscussionParticipant?, date: Date?, attachment: File?, isTopic: Bool) -> String {
        guard author != nil || date != nil || attachment != nil else { return "" }
        return """
        <div class="\(Styles.entryHeader)\(isTopic ? " \(Styles.topicHeader)" : "")">
            \(avatarLink(for: author, isTopic: isTopic))
            <div style="flex:1">
                \(author.map { """
                    <div class="\(Styles.authorName)" aria-hidden="true">
                        \(t($0.displayName))
                    </div>
                """ } ?? "")
                \(date.map { """
                    <div class="\(Styles.date)">\(t($0.dateTimeString))</div>
                """ } ?? "")
            </div>
            \(attachment.map { """
                <a class="\(Styles.blockLink)" href="\(t($0.url?.absoluteString))" aria-label="\(t($0.displayName))">
                    \(paperclipIcon)
                </a>
            """ } ?? "")
        </div>
        """
    }

    static func avatarLink(for author: DiscussionParticipant?, isTopic: Bool) -> String {
        guard let author = author else { return "" }
        var classes = "\(Styles.avatar)"
        if isTopic { classes += " \(Styles.avatarTopic)" }
        var style = ""
        var content = ""
        if let url = Avatar.scrubbedURL(author.avatarURL)?.absoluteString {
            style += "style=\"background-image:url(\(t(url)))\""
        } else {
            content = t(Avatar.initials(for: author.name))
            classes += " \(Styles.avatarInitials)"
        }
        return """
        <a class="\(Styles.blockLink)" href="../users/\(author.id)" aria-label="\(t(author.displayName))">
            <div aria-hidden="true" class="\(classes)" \(style)>\(content)</div>
        </a>
        """
    }

    static func message(for entry: DiscussionEntry) -> String {
        if entry.isRemoved {
            return """
            <p class="\(Styles.deleted)">
                \(t(String(localized: "Deleted this reply.", bundle: .core)))
            </p>
            """
        }
        return entry.message?
            .replacingOccurrences(of: "<script(.+)</script>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "<link[^>]*>", with: "", options: .regularExpression) ?? ""
    }

    // Preact-based rendering for updatable content

    static func render(
        topic: DiscussionTopic,
        entries: [DiscussionEntry],
        maxDepth: UInt,
        canLike: Bool,
        groups: [Group]?,
        contextColor: UIColor?
    ) -> String {
        """
        preact.render(preact.h(Discussion, {
            topic: \(js(topic: topic, groups: groups)),
            entries: [\(entries.map {
                js(entry: $0, depth: 0, maxDepth: maxDepth)
            } .joined(separator: ",\n"))],
            maxDepth: \(maxDepth),
            canLike: \(canLike),
            contextColor: \(s(contextColor?.hexString))
        }), Discussion.element)
        Discussion.fixCustomJS()
        fixLTITools()
        """
    }

    static func render(
        entry: DiscussionEntry,
        in topic: DiscussionTopic,
        maxDepth: UInt,
        canLike: Bool
    ) -> String {
        """
        preact.render(preact.h(Discussion.Entry, {
            topic: \(js(topic: topic)),
            entry: \(js(entry: entry, depth: 0, maxDepth: maxDepth)),
            depth: 0,
            maxDepth: \(maxDepth),
            canLike: \(canLike)
        }), Discussion.element)
        """
    }

    static func rerenderActions(
        for entry: DiscussionEntry,
        in topic: DiscussionTopic,
        canLike: Bool,
        overrideLiked: Bool? = nil
    ) -> String {
        """
        (actions =>
            preact.render(preact.h(Discussion.EntryActions, {
                topic: \(js(topic: topic)),
                entry: \(js(entry: entry, depth: 0, maxDepth: 1, overrideLiked: overrideLiked)),
                canLike: \(canLike)
            }), actions.parentNode, actions)
        )(document.querySelector('#actions-\(entry.id)'))
        """
    }

    static func js(topic: DiscussionTopic, groups: [Group]? = nil) -> String {
        """
        {allowRating:\(topic.allowRating),
        attachment:\(js(file: topic.attachments?.first)),
        author:\(js(participant: topic.author)),
        canReply:\(topic.canReply),
        date:\(s(topic.postedAt?.dateTimeString)),
        groupTopicChildren:\(js(array: topic.groupTopicChildren.flatMap { children in
            groups?.compactMap { group in
                guard let topicID = children[group.id] else { return nil }
                return """
                {id:\(s(group.id)),
                topicID:\(s(topicID)),
                name:\(s(group.name))}
                """
            }
        })),
        id:\(s(topic.id)),
        lockedForUser:\(topic.lockedForUser),
        message:\(s(topic.message))}
        """
    }

    static func js(entry: DiscussionEntry, depth: UInt, maxDepth: UInt, overrideLiked: Bool? = nil) -> String {
        """
        {attachment:\(entry.isRemoved ? "null" : js(file: entry.attachment)),
        author:\(js(participant: entry.author)),
        date:\(s(entry.updatedAt?.dateTimeString)),
        id:\(s(entry.id)),
        isLiked:\(overrideLiked ?? entry.isLikedByMe),
        isRead:\(entry.isRead),
        isRemoved:\(entry.isRemoved),
        likeCountShort:\(s(entry.likeCount <= 0 ? nil : String.localizedStringWithFormat(
            String(localized: "(%d)", bundle: .core, comment: "number of likes next to the like button"),
            entry.likeCount
        ))),
        likeCountText:\(s(entry.likeCount > 0 ? entry.likeCountText : "")),
        message:\(s(message(for: entry))),
        replies:\(js(array: entry.replies.isEmpty ? nil : depth >= maxDepth ? [] : entry.replies.map { js(entry: $0, depth: depth + 1, maxDepth: maxDepth)
        }))}
        """
    }

    static func js(participant: DiscussionParticipant?) -> String {
        guard let participant = participant else { return "null" }
        return """
        {id:\(s(participant.id)),
        initials:\(s(Avatar.initials(for: participant.name))),
        avatarURL:\(s(Avatar.scrubbedURL(participant.avatarURL)?.absoluteString)),
        displayName:\(s(participant.displayName))}
        """
    }

    static func js(file: File?) -> String {
        guard let file = file else { return "null" }
        return "{displayName:\(s(file.displayName)),url:\(s(file.url?.absoluteString))}"
    }

    static func js(array: [String]?) -> String {
        array.map { "[\($0.joined(separator: ","))]" } ?? "null"
    }

    static var preact: String {
        // swiftlint:disable:next force_try
        try! String(contentsOf: Bundle.core.url(forResource: "preact.min", withExtension: "js")!, encoding: .utf8)
    }

    static let js = """
    const { h, Fragment } = preact
    const classList = (classes) => classes.filter(Boolean).join(' ')

    window.Discussion = (props) => {
        const { topic, entries, maxDepth, canLike } = props
        return h(Fragment, null,
            h(Discussion.Header, topic),
            h('div', { class: \(s(.message)), dangerouslySetInnerHTML: { __html: topic.message } }),
            h(Discussion.ReplyButton, topic),
            h(Discussion.GroupTopicChildren, props),
            entries.length > 0 && h('h2', { class: \(s(.heading)) },
                \(s(String(localized: "Replies", bundle: .core)))
            ),
            entries.map(entry => h(Discussion.Entry, { key: entry.id, topic, entry, depth: 0, maxDepth, canLike }))
        )
    }

    Discussion.Header = ({ author, date, attachment, canReply }) => {
        if (!author && !date && !attachment) { return null }
        const isTopic = canReply != null
        return h('div', { class: classList([ \(s(.entryHeader)), isTopic && \(s(.topicHeader)) ]) },
            h(Discussion.Avatar, { author, isTopic }),
            h('div', { style: 'flex:1' },
                author && h('div', { class: \(s(.authorName)), 'aria-hidden': 'true' },
                    author.displayName
                ),
                date && h('div', { class: \(s(.date)) }, date)
            ),
            attachment && h('a', {
                class: \(s(.blockLink)),
                href: attachment.url,
                'aria-label': attachment.displayName,
                dangerouslySetInnerHTML: { __html: \(s(paperclipIcon)) }
            })
        )
    }

    Discussion.Avatar = ({ author, isTopic }) => author && h('a', {
        class: \(s(.blockLink)),
        href: `../users/${author.id}`,
        'aria-label': author.displayName
    },
        h('div', {
            'aria-hidden': 'true',
            class: [
                \(s(.avatar)),
                isTopic && \(s(.avatarTopic)),
                !author.avatarURL && \(s(.avatarInitials))
            ].filter(Boolean).join(' '),
            style: author.avatarURL && `background-image:url(${author.avatarURL})`
        }, !author.avatarURL && author.initials)
    )


    Discussion.ReplyButton = ({ canReply, id, lockedForUser }) => {
        if (lockedForUser || !canReply) { return null }
        return h('div', { style: 'display:flex; margin:24px 0 16px 0;' },
            h('a', {
                style: '\(Styles.font(.semibold, 16))text-decoration:none',
                href: `${id}/reply`,
                'aria-label': \(s(String(localized: "Reply to main discussion", bundle: .core)))
            },
                \(s(String(localized: "Reply", bundle: .core)))
            )
        )
    }

    Discussion.GroupTopicChildren = ({ topic: { groupTopicChildren }, contextColor }) => {
        if (!groupTopicChildren || groupTopicChildren.length === 0 || !contextColor) { return null }
        return h(Fragment, null,
            h('div', { class: \(s(.divider)) }),
            h('div', { class: \(s(.groupTopicChildren)), style: `background:${contextColor}33` },
                h('p', null, \(s(String(localized:
                    "Since this is a group discussion, each group has its own conversation for this topic. Here are the discussions you have access to.",
                    bundle: .core
                )))),
                groupTopicChildren.map(({ id, name, topicID }) => h('a', {
                    key: id,
                    href: `/groups/${id}/discussion_topics/${topicID}`,
                    class: \(s(.groupTopicChild))
                },
                    h('span', { style: 'flex:1' }, name),
                    h('svg', { width: 24, height: 24, 'aria-hidden': 'true' },
                        h('path', { fill: 'currentColor', d: 'M8 7L9.5 5.5L16 12L9.5 18.5L8 17L13 12L8 7Z' })
                    )
                ))
            )
        )
    }

    Discussion.Entry = ({ topic, entry, depth, maxDepth, canLike }) => h('div', {
        id: `entry-${entry.id}`,
        class: \(s(.entry))
    },
        h('div', { class: entry.isRead ? \(s(.read)) : \(s(.unread)) },
            \(s(String(localized: "Unread", bundle: .core)))
        ),
        h(Discussion.Header, entry),
        h('div', { class: \(s(.entryContent)) },
            h('div', {
                id: `message-${entry.id}`,
                dangerouslySetInnerHTML: { __html: entry.message }
            }),
            h(Discussion.EntryActions, { topic, entry, canLike }),
            depth >= maxDepth && entry.replies && h('a', {
                href: `${topic.id}/replies/${entry.id}`,
                class: \(s(.moreReplies))
            },
                \(s(String(localized: "View more replies", bundle: .core)))
            ),
            depth < maxDepth && entry.replies && entry.replies.map(entry =>
                h(Discussion.Entry, { key: entry.id, topic, entry, depth: depth + 1, maxDepth, canLike })
            )
        )
    )

    Discussion.EntryActions = ({ topic, entry, canLike }) => {
        if (entry.isRemoved) { return null }
        return h('div', { id: `actions-${entry.id}`, class: \(s(.actions)) },
            !topic.lockedForUser && topic.canReply && h(Fragment, null,
                h('a', {
                    href: `${topic.id}/entries/${entry.id}/replies`,
                    class: \(s(.reply)),
                    'aria-label': \(s(String(localized: "Reply to thread", bundle: .core)))
                },
                    \(s(String(localized: "Reply", bundle: .core)))
                ),
                h('div', { class: \(s(.replyPipe)) })
            ),
            h('button', {
                "aria-label": \(s(String(localized: "Show more options", bundle: .core))),
                class: \(s(.moreOptions)),
                onClick: event => {
                    const button = event.target.closest(".\(Styles.moreOptions)")
                    const { x, y, width, height } = button.getBoundingClientRect()
                    const rect = { x: x + scrollX, y: y + scrollY, width, height }
                    window.webkit.messageHandlers.moreOptions.postMessage({ entryID: entry.id, rect })
                }
            },
                h('svg', { class: \(s(.icon)), 'aria-hidden': 'true' },
                    h('circle', { r: 2, cx: 2, cy: 10 }),
                    h('circle', { r: 2, cx: 10, cy: 10 }),
                    h('circle', { r: 2, cx: 18, cy: 10 })
                )
            ),
            h('span', { style: 'flex:1' }),
            topic.allowRating && (!canLike ? entry.likeCountText : h('div', {
                class: classList([ \(s(.like)), entry.isLiked && \(s(.liked)) ]),
            },
                h('span', { class: \(s(.screenreader)) }, entry.likeCountText),
                h('span', { 'aria-hidden': 'true' }, entry.likeCountShort),
                h('label', { class: \(s(.likeIcon)) },
                    h('input', {
                        type: 'checkbox',
                        checked: entry.isLiked,
                        class: \(s(.hiddenCheck)),
                        'aria-label': \(s(String(localized: "Like", bundle: .core, comment: "like action"))),
                        onInput: event => {
                            window.webkit.messageHandlers.like.postMessage({ entryID: entry.id, isLiked: event.target.checked })
                        }
                    }),
                    h('svg', { class: \(s(.icon)), 'aria-hidden': 'true', viewBox: '0 0 1920 1920' },
                        h('path', { style: entry.isLiked ? null : 'opacity:0', d: `
        M1863.059 1016.47c0-124.574-101.308-225.882-225.883-225.882H1203.37c-19.651 0-37.044-9.374
        -47.66-25.863-10.391-16.15-11.86-35.577-3.84-53.196 54.776-121.073 94.87-247.115 119.378
        -374.513 15.925-83.576-5.873-169.072-60.085-234.578C1157.29 37.384 1078.005 0 993.751 0
        H846.588v56.47c0 254.457-155.068 473.224-285.063 612.029-72.734 77.477-176.98 122.09
        -285.967 122.09H56v734.117C56 1742.682 233.318 1920 451.294 1920h960c124.574 0 225.882
        -101.308 225.882-225.882 0-46.42-14.117-89.676-38.174-125.59 87.869-30.947 151.116-114.862
        151.116-213.234 0-46.419-14.118-89.675-38.174-125.59 87.868-30.946 151.115-114.862 151.115
        -213.233
                        ` }),
                        h('path', { style: entry.isLiked ? 'opacity:0' : null, d: `
        M1637.176 1129.412h-112.94v112.94c62.23 0 112.94 50.599 112.94 112.942 0 62.344-50.71
        112.941-112.94 112.941h-112.942v112.941c62.23 0 112.941 50.598 112.941 112.942 0
        62.343-50.71 112.94-112.94 112.94h-960c-155.634 0-282.354-126.606-282.354-282.352
        V903.529h106.617c140.16 0 274.334-57.6 368.3-157.778C778.486 602.089 937.28 379.256
        957.385 112.94h36.367c50.484 0 98.033 22.363 130.334 61.44 32.64 39.53 45.854 91.144
        36.14 141.515-22.7 118.589-60.197 236.048-111.246 349.102-23.83 52.517-19.313 112.602
        11.746 160.94 31.397 48.566 84.706 77.591 142.644 77.591h433.807c62.231 0 112.942 50.598
        112.942 112.942 0 62.343-50.71 112.94-112.942 112.94m225.883-112.94c0-124.575-101.308
        -225.883-225.883-225.883H1203.37c-19.651 0-37.044-9.374-47.66-25.863-10.391-16.15-11.86
        -35.577-3.84-53.196 54.663-121.073 94.87-247.115 119.378-374.513 15.925-83.576-5.873
        -169.072-60.085-234.578C1157.29 37.384 1078.005 0 993.751 0H846.588v56.47c0 254.457
        -155.068 473.224-285.063 612.029-72.734 77.477-176.98 122.09-285.967 122.09H56v734.117
        C56 1742.682 233.318 1920 451.294 1920h960c124.574 0 225.882-101.308 225.882-225.882
        0-46.42-14.117-89.676-38.174-125.59 87.869-30.947 151.116-114.862 151.116-213.234 0-46.419
        -14.118-89.675-38.174-125.59 87.868-30.946 151.115-114.862 151.115-213.233
                        ` })
                    ) // svg
                ) // label
            )) // div rating
        ) // div actions
    }

    const scripts = new Set()
    Discussion.fixCustomJS = () => {
        for (const script of document.querySelectorAll('.\(Styles.message) script')) {
            const key = script.src || script.textContent
            if (scripts.has(key)) { continue }
            scripts.add(key)
            script.remove()
            const exec = document.createElement('script')
            exec.textContent = script.textContent
            for (let i = 0; i < script.attributes.length; ++i) {
                exec.setAttribute(script.attributes[i].name, script.attributes[i].value)
            }
            document.head.appendChild(exec)
        }
    }

    Discussion.element = document.createElement('div')
    document.body.appendChild(Discussion.element)
    window.webkit.messageHandlers.ready.postMessage('')
    """

    static let paperclipIcon = """
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1920" class="\(Styles.icon)" aria-hidden="true">
    <path d="
        M1752.77 221.1C1532.65 1 1174.28 1 954.17 221.1l-838.6 838.6c-154.05 154.16-154.05 404.9 0 558.94
        149.54 149.42 409.98 149.31 559.06 0l758.74-758.62c87.98-88.1 87.98-231.42 0-319.51-88.32-88.21
        -231.64-87.98-319.51 0l-638.8 638.9 79.85 79.85 638.8-638.9c43.93-43.83 115.54-43.94 159.81 0
        43.93 44.04 43.93 115.87 0 159.8L594.78 1538.8c-110.23 110.12-289.35 110-399.36 0-110.12-110.11-110
        -289.24 0-399.24l838.59-838.6c175.96-175.95 462.38-176.18 638.9 0 176.08 176.2 176.08 462.84 0
        638.92l-798.6 798.72 79.85 79.85 798.6-798.72c220.02-220.13 220.02-578.49 0-798.61"/>
    </svg>
    """

    enum Styles: Int, CustomStringConvertible {
        case authorName, date, entryHeader, topicHeader
        case avatar, avatarInitials, avatarTopic
        case message, groupTopicChild, groupTopicChildren
        case deleted, entry, entryContent, moreReplies, read, unread
        case actions, like, liked, likeIcon, moreOptions, reply, replyPipe
        case blockLink, divider, heading, hiddenCheck, icon, mirrorRTL, screenreader

        var description: String { "-i\(String(rawValue, radix: 36))" }

        static func color(_ path: KeyPath<Brand, UIColor>, style: UIUserInterfaceStyle = .light) -> String {
            Brand.shared[keyPath: path].hexString(for: style)
        }
        static func color(_ color: UIColor, style: UIUserInterfaceStyle = .light) -> String {
            color.hexString(for: style)
        }

        enum Weight: String {
            case regular = "400"
            case medium = "500"
            case semibold = "600"
            case bold = "700"
        }
        static func font(_ weight: Weight, _ size: CGFloat) -> String {
            "font-weight:\(weight.rawValue);font-size:\(size / 16)rem;"
        }
    }

    static let css = (lightCss + darkCss).replacingOccurrences(of: "\\s*([{}:;,])\\s*", with: "$1", options: .regularExpression)

    static let darkCss = """
    @media (prefers-color-scheme: dark) {
    body {
        color: \(Styles.color(.textDarkest, style: .dark));
        \(Styles.font(.medium, 14))
        --max-lines: none;
    }

    .\(Styles.authorName) {
        color: \(Styles.color(.textDarkest, style: .dark));
        \(Styles.font(.semibold, 14))
        --max-lines: 2;
    }
    .\(Styles.date) {
        color: \(Styles.color(.textDark, style: .dark));
        \(Styles.font(.semibold, 12))
        margin-top: 2px;
        --max-lines: 2;
    }
    \(""/* 2 lines then ellipsis */)
    .\(Styles.authorName),
    .\(Styles.date) {
        overflow: hidden;
        word-break: break-all;
        display: -webkit-box;
        -webkit-box-orient: vertical;
        -webkit-line-clamp: var(--max-lines);
    }
    .\(Styles.entryHeader) {
        align-items: center;
        display: flex;
        margin: 12px 0;
    }
    .\(Styles.topicHeader) {
        margin: 16px 0;
    }

    .\(Styles.avatar) {
        background: \(Styles.color(.backgroundLightest, style: .dark));
        background-size: cover;
        border-radius: 50%;
        box-sizing: border-box;
        color: \(Styles.color(.textDark, style: .dark));
        font-size: 14px;
        font-weight: 600;
        height: 32px;
        line-height: 32px;
        -webkit-margin-end: 8px;
        text-align: center;
        width: 32px;
    }
    .\(Styles.avatarInitials) {
        border: 1px solid \(Styles.color(.borderMedium, style: .dark));
        overflow: hidden;
    }
    .\(Styles.avatarTopic) {
        font-size: 18px;
        height: 40px;
        line-height: 40px;
        -webkit-margin-end: 12px;
        -webkit-margin-start: -2px;
        width: 40px;
    }

    .\(Styles.groupTopicChildren) {
        border-radius: 8px;
        display: flex;
        flex-flow: column;
        margin: 12px 0;
        padding-bottom: 12px;
    }
    .\(Styles.groupTopicChildren) > p {
        \(Styles.font(.medium, 14))
        margin: 12px;
    }
    .\(Styles.groupTopicChild) {
        color: \(Styles.color(.textDarkest, style: .dark));
        \(Styles.font(.semibold, 16))
        display: flex;
        margin: 12px 8px 12px 12px;
        text-decoration: none;
    }

    .\(Styles.deleted) {
        color: \(Styles.color(.textDark, style: .dark));
        font-style: italic;
    }
    .\(Styles.entry) {
        margin: 12px 0;
        position: relative;
    }
    .\(Styles.entry)::before {
        bottom: -8px;
        border-left: 1px solid \(Styles.color(.borderMedium, style: .dark));
        content: "";
        display: block;
        margin: 0 16px;
        position: absolute;
        top: 40px;
    }
    .\(Styles.entry):last-child::before {
        content: none;
    }
    .\(Styles.entryContent) {
        -webkit-margin-start: 40px;
    }
    .\(Styles.moreReplies) {
        background: none;
        border: 0.5px solid \(Styles.color(.borderMedium, style: .dark));
        border-radius: 4px;
        color: \(Styles.color(.textDark, style: .dark));
        display: block;
        font-size: 12px;
        margin: 12px 0;
        padding: 6px;
        text-align: center;
        text-decoration: none;
    }
    .\(Styles.read),
    .\(Styles.unread) {
        background: \(Styles.color(.backgroundInfo, style: .dark));
        border-radius: 3px;
        color: \(Styles.color(.backgroundInfo, style: .dark));
        height: 6px;
        -webkit-margin-start: -8px;
        overflow: hidden;
        position: absolute;
        width: 6px;
    }
    .\(Styles.unread) {
        transition: opacity 0.5s ease, transform 0.5s ease, visibility 0s linear 0s;
    }
    .\(Styles.read) {
        opacity: 0;
        visibility: hidden;
        transform: scale(0);
        transition: opacity 0.5s ease, transform 0.5s ease, visibility 0s linear 0.5s;
    }

    .\(Styles.actions) {
        align-items: center;
        color: \(Styles.color(.textDark, style: .dark));
        display: flex;
        margin: 12px 0;
    }
    .\(Styles.like) {
        align-items: center;
        display: flex;
        margin: -2px 0;
        transition: color 0.2s ease;
    }
    .\(Styles.liked) {
        color: \(Styles.color(\.linkColor, style: .dark));
    }
    .\(Styles.likeIcon) {
        display: flex;
        -webkit-margin-start: 6px;
        position: relative;
    }
    .\(Styles.likeIcon) path {
        transition: opacity 0.2s ease;
    }
    .\(Styles.moreOptions) {
        background: none;
        border: 0 none;
        color: inherit;
        display: flex;
        margin: -2px 0;
        padding: 0;
    }
    .\(Styles.reply) {
        color: \(Styles.color(.textDark, style: .dark));
        text-decoration: none;
    }
    .\(Styles.replyPipe) {
        border-left: 1px solid \(Styles.color(.borderMedium, style: .dark));
        height: 16px;
        margin: 0 12px;
        width: 0;
    }

    .\(Styles.blockLink) {
        color: \(Styles.color(.textDark, style: .dark));
        display: flex;
        text-decoration: none;
    }
    .\(Styles.divider) {
        border-top: 0.3px solid \(Styles.color(.borderMedium, style: .dark));
        margin: 16px -16px;
    }
    .\(Styles.heading) {
        border-top: 0.3px solid \(Styles.color(.borderMedium, style: .dark));
        border-bottom: 0.3px solid \(Styles.color(.borderMedium, style: .dark));
        \(Styles.font(.bold, 20))
        margin: 16px -16px;
        padding: 16px 16px 8px 16px;
    }
    .\(Styles.hiddenCheck) {
        height: 100%;
        left: 0;
        margin: 0;
        opacity: 0.001;
        position: absolute;
        top: 0;
        width: 100%;
    }
    .\(Styles.icon) {
        fill: currentcolor;
        height: 20px;
        padding: 2px;
        width: 20px;
    }
    [dir=rtl] .\(Styles.mirrorRTL) {
        transform: scaleX(-1);
    }
    .\(Styles.screenreader) {
        clip-path: inset(50%);
        height: 1px;
        overflow: hidden;
        width: 1px;
    }
    }
    """

    static let lightCss = """
    @media (prefers-color-scheme: light) {
    body {
        color: \(Styles.color(.textDarkest));
        \(Styles.font(.medium, 14))
        --max-lines: none;
    }

    .\(Styles.authorName) {
        color: \(Styles.color(.textDarkest));
        \(Styles.font(.semibold, 14))
        --max-lines: 2;
    }
    .\(Styles.date) {
        color: \(Styles.color(.textDark));
        \(Styles.font(.semibold, 12))
        margin-top: 2px;
        --max-lines: 2;
    }
    \(""/* 2 lines then ellipsis */)
    .\(Styles.authorName),
    .\(Styles.date) {
        overflow: hidden;
        word-break: break-all;
        display: -webkit-box;
        -webkit-box-orient: vertical;
        -webkit-line-clamp: var(--max-lines);
    }
    .\(Styles.entryHeader) {
        align-items: center;
        display: flex;
        margin: 12px 0;
    }
    .\(Styles.topicHeader) {
        margin: 16px 0;
    }

    .\(Styles.avatar) {
        background: \(Styles.color(.backgroundLightest));
        background-size: cover;
        border-radius: 50%;
        box-sizing: border-box;
        color: \(Styles.color(.textDark));
        font-size: 14px;
        font-weight: 600;
        height: 32px;
        line-height: 32px;
        -webkit-margin-end: 8px;
        text-align: center;
        width: 32px;
    }
    .\(Styles.avatarInitials) {
        border: 1px solid \(Styles.color(.borderMedium));
        overflow: hidden;
    }
    .\(Styles.avatarTopic) {
        font-size: 18px;
        height: 40px;
        line-height: 40px;
        -webkit-margin-end: 12px;
        -webkit-margin-start: -2px;
        width: 40px;
    }

    .\(Styles.groupTopicChildren) {
        border-radius: 8px;
        display: flex;
        flex-flow: column;
        margin: 12px 0;
        padding-bottom: 12px;
    }
    .\(Styles.groupTopicChildren) > p {
        \(Styles.font(.medium, 14))
        margin: 12px;
    }
    .\(Styles.groupTopicChild) {
        color: \(Styles.color(.textDarkest));
        \(Styles.font(.semibold, 16))
        display: flex;
        margin: 12px 8px 12px 12px;
        text-decoration: none;
    }

    .\(Styles.deleted) {
        color: \(Styles.color(.textDark));
        font-style: italic;
    }
    .\(Styles.entry) {
        margin: 12px 0;
        position: relative;
    }
    .\(Styles.entry)::before {
        bottom: -8px;
        border-left: 1px solid \(Styles.color(.borderMedium));
        content: "";
        display: block;
        margin: 0 16px;
        position: absolute;
        top: 40px;
    }
    .\(Styles.entry):last-child::before {
        content: none;
    }
    .\(Styles.entryContent) {
        -webkit-margin-start: 40px;
    }
    .\(Styles.moreReplies) {
        background: none;
        border: 0.5px solid \(Styles.color(.borderMedium));
        border-radius: 4px;
        color: \(Styles.color(.textDark));
        display: block;
        font-size: 12px;
        margin: 12px 0;
        padding: 6px;
        text-align: center;
        text-decoration: none;
    }
    .\(Styles.read),
    .\(Styles.unread) {
        background: \(Styles.color(.backgroundInfo));
        border-radius: 3px;
        color: \(Styles.color(.backgroundInfo));
        height: 6px;
        -webkit-margin-start: -8px;
        overflow: hidden;
        position: absolute;
        width: 6px;
    }
    .\(Styles.unread) {
        transition: opacity 0.5s ease, transform 0.5s ease, visibility 0s linear 0s;
    }
    .\(Styles.read) {
        opacity: 0;
        visibility: hidden;
        transform: scale(0);
        transition: opacity 0.5s ease, transform 0.5s ease, visibility 0s linear 0.5s;
    }

    .\(Styles.actions) {
        align-items: center;
        color: \(Styles.color(.textDark));
        display: flex;
        margin: 12px 0;
    }
    .\(Styles.like) {
        align-items: center;
        display: flex;
        margin: -2px 0;
        transition: color 0.2s ease;
    }
    .\(Styles.liked) {
        color: \(Styles.color(\.linkColor));
    }
    .\(Styles.likeIcon) {
        display: flex;
        -webkit-margin-start: 6px;
        position: relative;
    }
    .\(Styles.likeIcon) path {
        transition: opacity 0.2s ease;
    }
    .\(Styles.moreOptions) {
        background: none;
        border: 0 none;
        color: inherit;
        display: flex;
        margin: -2px 0;
        padding: 0;
    }
    .\(Styles.reply) {
        color: \(Styles.color(.textDark));
        text-decoration: none;
    }
    .\(Styles.replyPipe) {
        border-left: 1px solid \(Styles.color(.borderMedium));
        height: 16px;
        margin: 0 12px;
        width: 0;
    }

    .\(Styles.blockLink) {
        color: \(Styles.color(.textDark));
        display: flex;
        text-decoration: none;
    }
    .\(Styles.divider) {
        border-top: 0.3px solid \(Styles.color(.borderMedium));
        margin: 16px -16px;
    }
    .\(Styles.heading) {
        border-top: 0.3px solid \(Styles.color(.borderMedium));
        border-bottom: 0.3px solid \(Styles.color(.borderMedium));
        \(Styles.font(.bold, 20))
        margin: 16px -16px;
        padding: 16px 16px 8px 16px;
    }
    .\(Styles.hiddenCheck) {
        height: 100%;
        left: 0;
        margin: 0;
        opacity: 0.001;
        position: absolute;
        top: 0;
        width: 100%;
    }
    .\(Styles.icon) {
        fill: currentcolor;
        height: 20px;
        padding: 2px;
        width: 20px;
    }
    [dir=rtl] .\(Styles.mirrorRTL) {
        transform: scaleX(-1);
    }
    .\(Styles.screenreader) {
        clip-path: inset(50%);
        height: 1px;
        overflow: hidden;
        width: 1px;
    }
    }
    """
}
