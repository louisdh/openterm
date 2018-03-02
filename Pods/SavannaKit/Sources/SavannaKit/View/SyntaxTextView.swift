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

#if os(macOS)

	private class TextViewWrapperView: View {
		
		var textView: InnerTextView?
		
		override public func draw(_ rect: CGRect) {

			guard let textView = textView else {
				return
			}
		
			let contentHeight = textView.enclosingScrollView!.documentView!.bounds.height
			
			let yOffset = self.bounds.height - contentHeight
			
			var paragraphs: [Paragraph]
			
			if let cached = textView.cachedParagraphs {
				
				paragraphs = cached
				
			} else {
				
				paragraphs = generateParagraphs(for: textView, flipRects: true)
				textView.cachedParagraphs = paragraphs
			
			}
			
			paragraphs = offsetParagrahps(paragraphs, for: textView, yOffset: yOffset)

			let components = textView.text.components(separatedBy: .newlines)
			
			let count = components.count
			
			let maxNumberOfDigits = "\(count)".count
			
			textView.updateGutterWidth(for: maxNumberOfDigits)
			
			Color.black.setFill()
			
			let gutterRect = CGRect(x: 0, y: 0, width: textView.gutterWidth, height: rect.height)
			let path = BezierPath(rect: gutterRect)
			path.fill()
			
			
			drawLineNumbers(paragraphs, in: self.bounds, for: textView)
			
		}
		
	}
	
#endif

extension TextView {
	
	func paragraphRectForRange(range: NSRange) -> CGRect {
		
		var nsRange = range
		
		let layoutManager: NSLayoutManager
		let textContainer: NSTextContainer
		#if os(macOS)
			layoutManager = self.layoutManager!
			textContainer = self.textContainer!
		#else
			layoutManager = self.layoutManager
			textContainer = self.textContainer
		#endif
		
		nsRange = layoutManager.glyphRange(forCharacterRange: nsRange, actualCharacterRange: nil)
		
		var sectionRect = layoutManager.boundingRect(forGlyphRange: nsRange, in: textContainer)
		
		// FIXME: don't use this hack
		// This gets triggered for the final paragraph in a textview if the next line is empty (so the last paragraph ends with a newline)
		if sectionRect.origin.x == 0 {
			sectionRect.size.height -= 22
		}
		
		sectionRect.origin.x = 0
		
		return sectionRect
	}
	
}

func generateParagraphs(for textView: InnerTextView, flipRects: Bool = false) -> [Paragraph] {

	let range = NSRange(location: 0, length: textView.text.count)
	
	var paragraphs = [Paragraph]()
	var i = 0
	
	(textView.text as NSString).enumerateSubstrings(in: range, options: [.byParagraphs]) { (paragraphContent, paragraphRange, enclosingRange, stop) in
		
		i += 1
		
		let rect = textView.paragraphRectForRange(range: paragraphRange)
		
		let paragraph = Paragraph(rect: rect, number: i)
		paragraphs.append(paragraph)
		
	}
	
	if textView.text.isEmpty || textView.text.hasSuffix("\n") {
		
		var rect: CGRect
		
		#if os(macOS)
			let gutterWidth = textView.textContainerInset.width
		#else
			let gutterWidth = textView.textContainerInset.left
		#endif
		
		let lineHeight: CGFloat = 22
		
		if let last = paragraphs.last {
			
			rect = CGRect(x: 0, y: last.rect.origin.y + last.rect.height, width: gutterWidth, height: lineHeight)
			
		} else {
			
			rect = CGRect(x: 0, y: 0, width: gutterWidth, height: lineHeight)
			
		}
		
		
		i += 1
		let endParagraph = Paragraph(rect: rect, number: i)
		paragraphs.append(endParagraph)
		
	}
	
	
	if flipRects {
		
		paragraphs = paragraphs.map { (p) -> Paragraph in
			
			var p = p
			p.rect.origin.y = textView.bounds.height - p.rect.height - p.rect.origin.y
			
			return p
		}
		
	}
	
	return paragraphs
}

func offsetParagrahps(_ paragraphs: [Paragraph], for textView: InnerTextView, yOffset: CGFloat = 0) -> [Paragraph] {

	var paragraphs = paragraphs
	
	#if os(macOS)
		
		if let yOffset = textView.enclosingScrollView?.contentView.bounds.origin.y {
			
			paragraphs = paragraphs.map { (p) -> Paragraph in
				
				var p = p
				p.rect.origin.y += yOffset
				
				return p
			}
		}
		
		
	#endif
	

	
	paragraphs = paragraphs.map { (p) -> Paragraph in
		
		var p = p
		p.rect.origin.y += yOffset
		return p
	}
	
	return paragraphs
}

func drawLineNumbers(_ paragraphs: [Paragraph], in rect: CGRect, for textView: InnerTextView) {

	for paragraph in paragraphs {
		
		guard paragraph.rect.intersects(rect) else {
			continue
		}
		
		let attr = paragraph.attributedString(for: textView.theme)
		
		var drawRect = paragraph.rect
		
		let gutterWidth = textView.gutterWidth
		
		
		let drawSize = attr.size()
		
		drawRect.origin.x = gutterWidth - drawSize.width - 4
		
		#if os(macOS)
			drawRect.origin.y -= 22 - drawSize.height
		#else
			drawRect.origin.y += 22 - drawSize.height
		#endif
		drawRect.size.width = drawSize.width

		attr.draw(in: drawRect)
		
	}
	
}


public protocol SyntaxTextViewDelegate: class {
	
	func didChangeText(_ syntaxTextView: SyntaxTextView)

	func lexerForSource(_ source: String) -> Lexer
	
}

public class SyntaxTextView: View {

	fileprivate let textView: InnerTextView
	
	public weak var delegate: SyntaxTextViewDelegate?
	
	#if os(macOS)
	
	fileprivate let wrapperView = TextViewWrapperView()

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

			self.addSubview(scrollView)
			
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
			#else
				textView.text = newValue
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

#if os(macOS)
	
	extension SyntaxTextView: NSTextViewDelegate {
		
		public func textDidChange(_ notification: Notification) {
			guard let textView = notification.object as? NSTextView, textView == self.textView else {
				return
			}

			self.textView.invalidateCachedParagraphs()
			
			if let delegate = delegate {
				colorTextView(lexerForSource: { (source) -> Lexer in
					return delegate.lexerForSource(source)
				})
			}
			
			wrapperView.setNeedsDisplay(wrapperView.bounds)
			self.delegate?.didChangeText(self)

		}
		
	}
	
#endif

#if os(iOS)

	extension SyntaxTextView: UITextViewDelegate {
		
		public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
			
			return true
		}
		
		public func textViewDidChange(_ textView: UITextView) {
			
			self.textView.invalidateCachedParagraphs()
			textView.setNeedsDisplay()
			
			if let delegate = delegate {
				colorTextView(lexerForSource: { (source) -> Lexer in
					return delegate.lexerForSource(source)
				})
			}
		
		}
		
	}

#endif
