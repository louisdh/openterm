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

	func didChangeSelectedRange(_ syntaxTextView: SyntaxTextView, selectedRange: NSRange)
	
	func lexerForSource(_ source: String) -> Lexer
	
}

struct ThemeInfo {
	
	let theme: SyntaxColorTheme
	
	/// Width of a space character in the theme's font.
	/// Useful for calculating tab indent size.
	let spaceWidth: CGFloat
	
}

@IBDesignable
open class SyntaxTextView: View {

	var previousSelectedRange: NSRange?
	
	private var textViewSelectedRangeObserver: NSKeyValueObservation?

	let textView: InnerTextView
	
	public var contentTextView: TextView {
		return textView
	}
	
	public weak var delegate: SyntaxTextViewDelegate?
	
	var ignoreSelectionChange = false
	
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
	
	open override var tintColor: UIColor! {
		didSet {

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
	
	public override convenience init(frame: CGRect) {
		self.init(.frame(frame))!
	}
	
	public required convenience init?(coder aDecoder: NSCoder) {
		self.init(.coder(aDecoder))
	}
	
	private init?(_ initMethod: InitMethod) {
		
		let textStorage = NSTextStorage()
		let layoutManager = SyntaxTextViewLayoutManager()
		let containerSize = CGSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
		let textContainer = NSTextContainer(size: containerSize)
		
		textContainer.widthTracksTextView = true
		layoutManager.addTextContainer(textContainer)
		textStorage.addLayoutManager(layoutManager)
		
		self.textView = InnerTextView(frame: .zero, textContainer: textContainer)
		
		switch initMethod {
		case let .coder(coder): super.init(coder: coder)
		case let .frame(frame): super.init(frame: frame)
		}
		
		setup()
	}

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
		
			self.contentMode = .redraw
			textView.contentMode = .topLeft
		
			textViewSelectedRangeObserver = contentTextView.observe(\UITextView.selectedTextRange) { [weak self] (textView, value) in
			
				if let `self` = self {
					self.delegate?.didChangeSelectedRange(self, selectedRange: self.contentTextView.selectedRange)
				}

			}
			
		#endif
		
		textView.innerDelegate = self
		textView.delegate = self
		
		textView.text = ""
		textView.font = theme.font
		
		textView.backgroundColor = theme.backgroundColor
		
		#if os(iOS)

		backgroundColor = theme.backgroundColor

		textView.autocapitalizationType = .none
		textView.keyboardType = .default
		textView.autocorrectionType = .no
		textView.spellCheckingType = .no
			
		if #available(iOS 11.0, *) {
			textView.smartQuotesType = .no
			textView.smartInsertDeleteType = .no
		}
			
		textView.keyboardAppearance = .dark

		self.clipsToBounds = true
		
		#endif

	}
	
	#if os(macOS)
	
	open override func viewDidMoveToSuperview() {
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

	override open var isFirstResponder: Bool {
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
	
	public func insertText(_ text: String) {
		
		if shouldChangeText(insertingText: text) {
			
			contentTextView.insertText(text)
			
		}

	}
	
	#if os(iOS)

	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.textView.setNeedsDisplay()
	}
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		
		self.textView.invalidateCachedParagraphs()
		self.textView.setNeedsDisplay()

	}
	
	#endif

	public var theme: SyntaxColorTheme = DefaultTheme() {
		didSet {
			cachedThemeInfo = nil
		}
	}
	
	var cachedThemeInfo: ThemeInfo?
	
	var themeInfo: ThemeInfo {
		
		if let cached = cachedThemeInfo {
			return cached
		}
		
		let spaceAttrString = NSAttributedString(string: " ", attributes: [.font: theme.font])
		let spaceWidth = spaceAttrString.size().width
		
		let info = ThemeInfo(theme: theme, spaceWidth: spaceWidth)
		
		cachedThemeInfo = info
		
		return info
	}
	
	var cachedTokens: [CachedToken]?
	
	func invalidateCachedTokens() {
		cachedTokens = nil
	}
	
	func colorTextView(lexerForSource: (String) -> Lexer) {
		
		guard let source = textView.text else {
			return
		}
		
		let textStorage: NSTextStorage
		
		#if os(macOS)
			textStorage = textView.textStorage!
		#else
			textStorage = textView.textStorage
		#endif
		
		
//		self.backgroundColor = theme.backgroundColor
		
		
		let tokens: [Token]
		
		if let cachedTokens = cachedTokens {
			
			updateAttributes(textStorage: textStorage, cachedTokens: cachedTokens, source: source)
			
		} else {
			
			let lexer = lexerForSource(source)
			tokens = lexer.getSavannaTokens()
			
			let cachedTokens: [CachedToken] = tokens.map {
				
				if let range = $0.range {
					let nsRange = source.nsRange(fromRange: range)
					return CachedToken(token: $0, nsRange: nsRange)
				} else {
					return CachedToken(token: $0, nsRange: nil)
				}
				
			}

			self.cachedTokens = cachedTokens
			
			createAttributes(textStorage: textStorage, cachedTokens: cachedTokens, source: source)
			
		}
		
	}

	func updateAttributes(textStorage: NSTextStorage, cachedTokens: [CachedToken], source: String) {

		let selectedRange = textView.selectedRange
		
		let fullRange = NSRange(location: 0, length: (source as NSString).length)
		
		var rangesToUpdate = [(NSRange, EditorPlaceholderState)]()
		
		textStorage.enumerateAttribute(.editorPlaceholder, in: fullRange, options: []) { (value, range, stop) in
			
			if let state = value as? EditorPlaceholderState {
				
				var newState: EditorPlaceholderState = .inactive
				
				if isEditorPlaceholderSelected(selectedRange: selectedRange, tokenRange: range) {
					newState = .active
				}
				
				if newState != state {					
					rangesToUpdate.append((range, newState))
				}
				
			}
		
		}
		
		var didBeginEditing = false
		
		if !rangesToUpdate.isEmpty {
			textStorage.beginEditing()
			didBeginEditing = true
		}
		
		for (range, state) in rangesToUpdate {
			
			var attr = [NSAttributedStringKey: Any]()
			attr[.editorPlaceholder] = state

			textStorage.addAttributes(attr, range: range)

		}
		
		if didBeginEditing {
			textStorage.endEditing()
		}

	}
	
	func createAttributes(textStorage: NSTextStorage, cachedTokens: [CachedToken], source: String) {
		
		textStorage.beginEditing()

		var attributes = [NSAttributedStringKey: Any]()
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.paragraphSpacing = 2.0
		paragraphStyle.defaultTabInterval = themeInfo.spaceWidth * 4
		paragraphStyle.tabStops = []
		
		let wholeRange = NSRange(location: 0, length: (source as NSString).length)
		
		attributes[.foregroundColor] = theme.color(for: .plain)
		attributes[.font] = theme.font
		attributes[.paragraphStyle] = paragraphStyle
		
		textStorage.setAttributes(attributes, range: wholeRange)
		
		let selectedRange = textView.selectedRange
		
		for cachedToken in cachedTokens {
			
			let token = cachedToken.token
			
			let syntaxColorType = token.savannaTokenType.syntaxColorType
			
			if syntaxColorType == .plain {
				continue
			}
			
			guard let range = cachedToken.nsRange else {
				continue
			}

			if case .editorPlaceholder = syntaxColorType {
				
				let startRange = NSRange(location: range.lowerBound, length: 2)
				let endRange = NSRange(location: range.upperBound - 2, length: 2)
				
				let contentRange = NSRange(location: range.lowerBound + 2, length: range.length - 4)
				
				let color = theme.color(for: syntaxColorType)
				
				var attr = [NSAttributedStringKey: Any]()
				
				var state: EditorPlaceholderState = .inactive
				
				if isEditorPlaceholderSelected(selectedRange: selectedRange, tokenRange: range) {
					state = .active
				}
				
				attr[.editorPlaceholder] = state
				
				textStorage.addAttributes([.foregroundColor: color], range: contentRange)
				
				textStorage.addAttributes([.foregroundColor: Color.clear, .font: Font.systemFont(ofSize: 0.01)], range: startRange)
				textStorage.addAttributes([.foregroundColor: Color.clear, .font: Font.systemFont(ofSize: 0.01)], range: endRange)
				
				textStorage.addAttributes(attr, range: range)
				continue
			}
			
			let color = theme.color(for: syntaxColorType)
			
			var attr = attributes
			attr[.foregroundColor] = color
			
			textStorage.setAttributes(attr, range: range)
			
		}
		
		textStorage.endEditing()
		
	}
	
}
