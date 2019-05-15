//
//  GerritModelHelper.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/4/26.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

extension Change {

    func isOurs() -> Bool {
        guard let owner = owner else {
            return false
        }
        guard let ldap = ConfigManager.shared.user else {
            return false
        }
        return owner.isUser(ldap)
    }

    func hasNewMessages(diffWith newChange: Change) -> Bool {
        // 如果没有变化，消息数是不变的
        return messages?.count != newChange.messages?.count
    }

    func hasNewEvent() -> Bool {
        guard let last = messages?.last?.author else {
            return false
        }
        guard let ldap = ConfigManager.shared.user else {
            return false
        }
        // 只要最新的 Message 不是自己导致，说明有更新或操作，就认为有新事件
        return !last.isUser(ldap)
    }

    func newMessages(baseOn originChange: Change) -> [Message] {
        var result = [Message]()
        guard let messages = messages else {
            return result
        }
        guard let origin = originChange.messages else {
            return messages
        }
        for new in messages {
            var found = false
            for old in origin {
                if new.id == old.id {
                    found = true
                    break
                }
            }
            if !found {
                result.append(new)
            }
        }
        return result
    }

    func isMerged() -> Bool {
        return status == "MERGED"
    }

    func mergedBy() -> String? {
        let prefix = "Change has been successfully merged by "
        guard let last = messages?.last,
            var message = last.message,
            message.hasPrefix(prefix) else {
            return nil
        }
        message.removeFirst(prefix.count)
        return message
    }

}

extension Author {

    func isUser(_ ldap: String) -> Bool {
        guard let username = username else {
            return false
        }
        return ldap == username
    }

    func avatarImage() -> NSImage? {
        if let currentUser = ConfigManager.shared.user,
            currentUser == username {
            return NSImage.init(named: NSImage.Name("AvatarMyself"))
        }
        var index = 0
        if let accountId = accountId {
            index = accountId % 46
        }
        return NSImage.init(named: NSImage.Name("Avatar\(index)"))
    }

}

extension Message {

}
