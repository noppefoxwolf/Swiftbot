import Foundation
import Commander

command(
  Option("token", default: "Slack Token")
) { (token) in
  print("SwiftBot is Running")
  let bot = SwiftBot(token: token)
  bot.run()
  RunLoop.main.run()
}.run()
