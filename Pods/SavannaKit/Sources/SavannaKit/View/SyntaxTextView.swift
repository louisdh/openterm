//
//  SyntaxTextView.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 23/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif

private enum InitMethod {
	case coder(NSCoder)
	case frame(CGRect)
}

public protocol SyntaxTextViewDelegate: class {
	
	func didChangeText(_ syntaxTextView: SyntaxTextView)

	func lexerForSource(_ source: String) -> Lexer
	
}

@IBDesignable
public class SyntaxTextView: View {

	let textView: InnerTextView
	
	public var contentTextView: TextView {
		return textView
	}
	
	public weak var delegate: SyntaxTextViewDelegate?
	
	#if os(macOS)
	
	let wrapperView = TextViewWrapperView()

	#endif
	
	#if os(iOS)

	public var contentInset: UIEdgeInsets = .zero {
		didSet {
			textView.contentInset = contentInset
			textView.scrollIndicatorInsets = contentInset
		}
	}
	
	public override var tintColor: UIColor! {
		didSet {
			keyboardToolbar.tintColor = tintColor
		}
	}
	
	#else
	
	public var tintColor: NSColor! {
		set {
			textView.tintColor = newValue
		}
		get {
			return textView.tintColor
		}
	}
	
	#endif
	
	override convenience init(frame: CGRect) {
		self.init(.frame(frame))!
	}
	
	public required convenience init?(coder aDecoder: NSCoder) {
		self.init(.coder(aDecoder))
	}
	
	private init?(_ initMethod: InitMethod) {

		textView = InnerTextView(frame: .zero)
		
		switch initMethod {
		case let .coder(coder): super.init(coder: coder)
		case let .frame(frame): super.init(frame: frame)
		}
		
		setup()
	}
	
	#if os(iOS)

		private var keyboardToolbar: UIToolbar!
	
	#endif

	#if os(macOS)

		public let scrollView = NSScrollView()

	#endif
	
	private func setup() {
	
		textView.gutterWidth = 20
		
		#if os(iOS)
			
			textView.translatesAutoresizingMaskIntoConstraints = false
			
		#endif
		
		#if os(macOS)

			wrapperView.translatesAutoresizingMaskIntoConstraints = false
			
			scrollView.backgroundColor = .clear
			scrollView.drawsBackground = false
			
			scrollView.contentView.backgroundColor = .clear
			
			scrollView.translatesAutoresizingMaskIntoConstraints = false

			addSubview(scrollView)
			
			addSubview(wrapperView)

			
			scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
			scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
			scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
			scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
			
			wrapperView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
			wrapperView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
			wrapperView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
			wrapperView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
			
			
			scrollView.borderType = .noBorder
			scrollView.hasVerticalScroller = true
			scrollView.hasHorizontalScroller = false
			scrollView.scrollerKnobStyle = .light
			
			scrollView.documentView = textView
			
			scrollView.contentView.postsBoundsChangedNotifications = true
			
			NotificationCenter.default.addObserver(self, selector: #selector(didScroll(_:)), name: NSView.boundsDidChangeNotification, object: scrollView.contentView)
			
			textView.minSize = NSSize(width: 0.0, height: self.bounds.height)
			textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
			textView.isVerticallyResizable = true
			textView.isHorizontallyResizable = false
			textView.autoresizingMask = .width
			textView.isEditable = true
			textView.isAutomaticQuoteSubstitutionEnabled = false
			textView.allowsUndo = true
			
			textView.textContainer?.containerSize = NSSize(width: self.bounds.width, height: .greatestFiniteMagnitude)
			textView.textContainer?.widthTracksTextView = true
			
//			textView.layerContentsRedrawPolicy = .beforeViewResize
			
			wrapperView.textView = textView
			
		#else
			
			self.addSubview(textView)
			textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
			textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
			textView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
			textView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		
		#endif
		
		textView.delegate = self
		
		textView.text = ""
		textView.font = theme.font
		
		textView.backgroundColor = theme.backgroundColor
		
		#if os(iOS)

		textView.autocapitalizationType = .none
		textView.keyboardType = .default
		textView.autocorrectionType = .no
		textView.spellCheckingType = .no
			
		if #available(iOS 11.0, *) {
			textView.smartQuotesType = .no
		}
			
		textView.keyboardAppearance = .dark
		
		
		keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 50.0))
		
		let equalsBtn = UIBarButtonItem(title: "=", style: .plain, target: self, action: #selector(test))
		
		let font = UIFont.systemFont(ofSize: 44.0)
		let attributes = [NSAttributedStringKey.font : font]

		equalsBtn.setTitleTextAttributes(attributes, for: .normal)
		
		keyboardToolbar.items = [equalsBtn]
		
//		textView.inputAccessoryView = keyboardToolbar
		
//		equalsBtn.tintColor = .red
		
		self.clipsToBounds = true
		
		#endif

	}
	
	#if os(macOS)
	
	public override func viewDidMoveToSuperview() {
		super.viewDidMoveToSuperview()
	
	}
	
	@objc func didScroll(_ notification: Notification) {
		
		wrapperView.setNeedsDisplay(wrapperView.bounds)
		
	}

	#endif

	#if os(iOS)

	@objc func test() {
			textView.insertText("=")
		}
		
	#endif


	// MARK: -
	
	#if os(iOS)

	public override var isFirstResponder: Bool {
		return textView.isFirstResponder
	}
	
	#endif

//	#if os(iOS)
//
//		override public func draw(_ rect: CGRect) {
//
//			let textView = self.textView
//
//			let components = textView.text.components(separatedBy: .newlines)
//
//			let count = components.count
//
//			let maxNumberOfDigits = "\(count)".count
//
//			textView.updateGutterWidth(for: maxNumberOfDigits)
//
//			Color.black.setFill()
//
//			let gutterRect = CGRect(x: 0, y: 0, width: textView.gutterWidth, height: bounds.height)
//			let path = BezierPath(rect: gutterRect)
//			path.fill()
//
//
//			super.draw(rect)
//		}
//
//	#endif
	
	@IBInspectable
	public var text: String {
		get {
			#if os(macOS)
				return textView.string
			#else
				return textView.text ?? ""
			#endif
		}
		set {
			#if os(macOS)
				textView.layer?.isOpaque = true

				textView.string = newValue
				
				self.didUpdateText()
				
			#else
				textView.text = newValue
				textView.setNeedsDisplay()
				self.didUpdateText()
			#endif
			
		}
	}
	
	// MARK: -
	
	#if os(iOS)

	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.textView.setNeedsDisplay()
	}
	
	override public func layoutSubviews() {
		super.layoutSubviews()
		
		self.textView.invalidateCachedParagraphs()
		self.textView.setNeedsDisplay()

	}
	
	#endif

	fileprivate lazy var theme: SyntaxColorTheme = {
		return DefaultTheme()
	}()
	
	func colorTextView(lexerForSource: (String) -> Lexer) {
		
		guard let string = textView.text else {
			return
		}
		
		let textStorage: NSTextStorage
		
		#if os(macOS)
			textStorage = textView.textStorage!
		#else
			textStorage = textView.textStorage
		#endif
		
		
		textStorage.beginEditing()
		
//		self.backgroundColor = theme.backgroundColor
		
		let lexer = lexerForSource(string)
		let tokens = lexer.getSavannaTokens()
		
		let attributedString = NSMutableAttributedString(string: string)
		
		var attributes = [NSAttributedStringKey: Any]()
		
		let wholeRange = NSRange(location: 0, length: string.count)
		attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: theme.color(for: .plain), range: wholeRange)
		attributedString.addAttribute(.font, value: theme.font, range: wholeRange)
		
		attributes[.foregroundColor] = theme.color(for: .plain)
		attributes[.font] = theme.font
		
		textStorage.setAttributes(attributes, range: wholeRange)

		
		for token in tokens {
			
			let syntaxColorType = token.savannaTokenType.syntaxColorType
			
			if syntaxColorType == .plain {
				continue
			}
			
			guard let tokenRange = token.range else {
				continue
			}
			
			guard let range = string.nsRange(fromRange: tokenRange) else {
				return
			}
			
			let color = theme.color(for: syntaxColorType)
			
			var attr = attributes
			attr[.foregroundColor] = color
			
			textStorage.setAttributes(attr, range: range)
			
		}
		
		textStorage.endEditing()

		//		sourceTextView.typingAttributes = attributedString.attributes
		//		sourceTextView.attributedText = attributedString
		
	}
	
}
