//
//  ChatMessage.swift
//  Strands
//
//  Created by Shresth Kapoor on 06/06/25.
//


import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: String
    let text: String
    let isUser: Bool
}
