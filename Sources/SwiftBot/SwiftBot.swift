//
//  SwiftBot.swift
//  SwiftBot
//
//  Created by Tomoya Hirano on 2018/12/23.
//

import Foundation
import SlackKit

class SwiftBot {
  let bot: SlackKit
  private var currentUserID: String? = nil
  
  init(token: String) {
    bot = SlackKit()
    bot.addWebAPIAccessWithToken(token)
    bot.addRTMBotWithAPIToken(token)
  }
  
  func run() {
    bot.webAPI?.authenticationTest(success: { [weak self] (user, team) in
      self?.currentUserID = user
    }, failure: { (error) in
      debugPrint(error)
    })
    bot.notificationForEvent(.message) { [weak self] (event, connection) in
      DispatchQueue.main.async { [weak self] in
        self?.didReceived(event: event, connection: connection)
      }
    }
  }
  
  private func didReceived(event: Event, connection: ClientConnection?) {
    do {
      guard let channel = event.channel?.id else { return }
      guard let currentUserID = currentUserID else { return }
      guard let sourceCode = try event.message?.sourceCode(userID: currentUserID)?.removingPercentEncoding?.convertSpecialCharacters else { return }
      let sandbox = Sandbox(code: sourceCode)
      sandbox.run(completed: { [weak self] (output) in
        self?.sendResult(channel: channel, body: output)
        }, errors: { [weak self] (error) in
          self?.sendResult(channel: channel, body: error)
      })
    } catch let error {
      debugPrint(error)
    }
  }
  
  private func sendResult(channel: String, body: String) {
    bot.webAPI?.sendMessage(channel: channel, text: "```\(body)```", success: { (response) in
      debugPrint(response)
    }, failure: { (error) in
      debugPrint(error)
    })
  }
}

extension Message {
  fileprivate func sourceCode(userID: String) throws -> String? {
    guard let text = self.text else { return nil }
    let pattern = "\\<\\@\(userID)\\>*\n```[A-Za-z]*\n([\\s\\S]*?\n)```"
    let regex = try NSRegularExpression(pattern: pattern)
    let range = NSRange(location: 0, length: text.count)
    guard let result = regex.firstMatch(in: text, options: [], range: range) else { return nil }
    guard result.numberOfRanges > 1 else { return nil }
    let body = (text as NSString).substring(with: result.range(at: 1))
    return body
  }
}

extension String {
  fileprivate var convertSpecialCharacters: String {
    var newString = self
    let char_dictionary = [
      "&amp;" : "&",
      "&lt;" : "<",
      "&gt;" : ">",
      "&quot;" : "\"",
      "&apos;" : "'"
    ];
    for (escaped_char, unescaped_char) in char_dictionary {
      newString = newString.replacingOccurrences(of: escaped_char, with: unescaped_char, options: NSString.CompareOptions.literal, range: nil)
    }
    return newString
  }
}
