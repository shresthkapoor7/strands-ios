//
//  Message.swift
//  Strands
//
//  Created by Shresth Kapoor on 06/06/25.
//


import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let chatId: String
    let sentBy: Int
    let text: String
    let createdAt: String
    let strand: Bool
    let parentChatId: String?
    let chatTitle: String?
    let userId: String
}
