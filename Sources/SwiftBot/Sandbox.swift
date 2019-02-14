//
//  Sandbox.swift
//  FileKit
//
//  Created by Tomoya Hirano on 2018/12/19.
//

import Foundation

class Sandbox {
  let tempDir: String
  let filename: String
  let toolchainVersion: String
  let command: String
  let options: [String]
  let code: String
  let timeout: Int
  
  init(filename: String = "main.swift",
       toolchainVersion: String = "4.2.1",
       command: String = "swift",
       options: [String] = [],
       code: String,
       timeout: Int = 10) {
    self.tempDir = "/tmp/SwiftBot/\(UUID().uuidString)"
    self.filename = filename
    self.toolchainVersion = toolchainVersion
    self.command = command
    self.options = options
    self.code = code
    
    var timeout = timeout
    if (timeout > 600) {
      timeout = 600;
    }
    self.timeout = timeout
  }
  
  func run(completed completedHandler: @escaping ((String) -> Void), errors errorsHandler: @escaping ((String) -> Void)) {
    do {
      let workDir: String = tempDir
      // ディレクトリの作成・削除
      let fm = FileManager.default
      try fm.createDirectory(at: URL(fileURLWithPath: workDir), withIntermediateDirectories: true, attributes: nil)
      
      // Swiftコードの配置
      let swiftFilePath = "\(workDir)/\(filename)"
      try code.write(to: URL(fileURLWithPath: swiftFilePath),
                     atomically: true, encoding: .utf8)
      
      // runスクリプトの配置
      try ShellScript.runSwift.write(to: URL(fileURLWithPath: workDir + "/script.sh"),
                                      atomically: true, encoding: .utf8)
      try ShellScript.runDocker.write(to: URL(fileURLWithPath: workDir + "/run.sh"),
                                      atomically: true, encoding: .utf8)
      
      // 実行
      let process = Process()
      process.executableURL = URL(fileURLWithPath: "/bin/sh")
      process.arguments = [
        workDir + "/run.sh",
        "\(timeout)s",
        "-v",
        "\(workDir):/usercode",
        "kishikawakatsumi/swift:4.2.1",
        "sh",
        "/usercode/script.sh",
        command,
        options.joined(separator: " ")
      ]
      process.launch()
      
      var counter: Int = 0
      func timerUpdated(_ timer: Timer) {
        
        counter += 1
        if counter > self.timeout {
          timer.invalidate()
        }
        
        var output: String = ""
        
        if fm.fileExists(atPath: workDir + "/completed") && fm.fileExists(atPath: workDir + "/errors") {
          timer.invalidate()
          do {
            let completed = try String(contentsOfFile: workDir + "/completed")
            let errors = try String(contentsOfFile: workDir + "/errors")
            let version = try String(contentsOfFile: workDir + "/version")
            output += version
            if !errors.isEmpty {
              output += errors
              debugPrint(output)
              errorsHandler(output)
              return
            }
            
            if !completed.isEmpty {
              output += completed
              debugPrint(output)
              completedHandler(output)
              return
            }
          } catch {
            debugPrint(error)
            errorsHandler(error.localizedDescription)
          }
        }
      }
      
      Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
        timerUpdated(timer)
      })
    } catch {
      debugPrint(error)
      errorsHandler(error.localizedDescription)
    }
  }
}
