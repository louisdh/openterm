//
//  Say.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 09/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import ios_system
import AVFoundation

@_cdecl("say")
public func say(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {

	guard let args = convertCArguments(argc: argc, argv: argv) else {
		return 1
	}
	
 	let usage = "Usage: say [-v voice] [message]\n"

	let parsed = SayCommandParser.parse(args: args)
	
	var voiceString: String?
	
	for (flag, flagContent) in parsed.flags {
		
		if flag != "v" {
			fputs("say: invalid option -- \(flag)\n", thread_stderr)
			return 1
		}
		
		voiceString = flagContent
	}
	
	let message: String
	
	if let parsedMessage = parsed.messageArgument {
		message = parsedMessage
		
	} else if voiceString == "?" {
		message = ""
		
	} else {
		
		let bytes = readStdinBytes()
		
		let data = Data(bytes: bytes, count: bytes.count)
		guard data.count > 0 else {
			fputs(usage, thread_stderr)
			return 1
		}
		
		guard let string = String(data: data, encoding: .utf8), !string.isEmpty else {
			fputs(usage, thread_stderr)
			return 1
		}
		
		message = string
	}
	
	let voice: AVSpeechSynthesisVoice?
	
	if let voiceString = voiceString {
		
		let speechVoices = AVSpeechSynthesisVoice.speechVoices()
		
		if voiceString == "?" {
			
			let voicesOutput = voicesHelpDescription(speechVoices)
			
			fputs(voicesOutput, thread_stdout)
			return 0
		}
		
		guard let namedVoice = speechVoices.first(where: { $0.name == voiceString }) else {
			fputs("say: Voice `\(voiceString)` not found.\n", thread_stderr)
			return 1
		}

		voice = namedVoice
		
	} else {
		
		voice = nil
		
	}
	
	let input = SayCommandInput(message: message, voice: voice)
	
	let executor = SayCommandExecutor(input: input)

	return executor.execute()
}

private func voicesHelpDescription(_ voices: [AVSpeechSynthesisVoice]) -> String {
	
	var voicesOutput = ""
	
	let maxVoiceNameLength = voices.map({ $0.name.count }).max() ?? 1
	
	for speechVoice in voices {
		
		var line = speechVoice.name + ""
		
		let extraSpaces = Array(repeating: " ", count: maxVoiceNameLength - speechVoice.name.count).joined()
		
		line += extraSpaces
		
		line += " \(speechVoice.language)"
		
		voicesOutput += "\(line)\n"
		
	}
	
	return voicesOutput
}

private struct SayCommandInput {
	
	let message: String
	let voice: AVSpeechSynthesisVoice?
	
}

private struct SayCommandParsed {
	
	let messageArgument: String?
	let flags: [String: String]
	
}

private class SayCommandParser {
	
	static func parse(args: [String]) -> SayCommandParsed {
		
		var message: String?
		
		var currentFlag: String?
		
		var flags = [String: String]()
		
		for arg in args.dropFirst() {
			
			if arg.hasPrefix("-") {
				currentFlag = String(arg.dropFirst())
				continue
			}
			
			if let currFlag = currentFlag {
				
				flags[currFlag] = arg
				
				currentFlag = nil
				
				continue
			}
			
			if message == nil {
				message = arg
			}
			
		}
		
		return SayCommandParsed(messageArgument: message, flags: flags)
	}
	
}

private class SayCommandExecutor {
	
	let input: SayCommandInput
	
	init(input: SayCommandInput) {
		self.input = input
	}
	
	func execute() -> Int32 {
		
		let synthesizer = AVSpeechSynthesizer()
		
		let semaphore = DispatchSemaphore(value: 0)
		
		let manager = AVSpeechSynthesizerManager(finishCallback: {
			
			semaphore.signal()
			
		})
		
		synthesizer.delegate = manager
		
		let utterance = AVSpeechUtterance(string: input.message)
		utterance.rate = 0.5
		utterance.pitchMultiplier = 1.0
		
		utterance.voice = input.voice
		
		synthesizer.speak(utterance)
		
		_ = semaphore.wait(timeout: .distantFuture)
		
		return 1
	}
	
}

private class AVSpeechSynthesizerManager: NSObject, AVSpeechSynthesizerDelegate {
	
	var finishCallback: () -> Void
	
	init(finishCallback: @escaping () -> Void) {
		self.finishCallback = finishCallback
		super.init()
	}
	
	func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
		
		finishCallback()
		
	}
	
}
