//
//  TabViewRootController.swift
//  TabView
//
//  Created by Ian McDowell on 2/6/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit

/// Represents the state of a tab view container.
/// Access the value of this using the `state` property.
public enum TabViewContainerState {
    /// There is a single tab view controller visible
    case single

    /// The container is split horizontally, with a secondary tab view controller on the right.
    case split
}

/// Internal protocol that the TabViewContainerViewController conforms to,
/// so other objects and reference it without knowing its generic type.
internal protocol TabViewContainer: class {
    /// Get the current state of the container
    var state: TabViewContainerState { get set }

    /// Get the primary tab view controller
    var primaryTabViewController: TabViewController { get }

    /// Get the secondary tab view controller, if there is one
    var secondaryTabViewController: TabViewController? { get }

    /// When a tab collection view starts dragging in either side, the container is alerted.
    /// This is done so the container can potentially enable a drop area to enter split view.
    func dragStateChanged(in tabViewController: TabViewController, to newDragState: Bool)

    /// Sets the inset of the stack view. This is done by the drop target when the user is hovering
    /// over the right side.
    var contentViewRightInset: CGFloat { get set }
}

/// A tab view container view controller manages the display of tab view controllers.
/// It can be in various states, as noted by its `state` property.
/// It's not required that you embed a tab view controller in a container, but if you want
/// the ability to go into split view, this is the suggested class to use.
open class TabViewContainerViewController<TabViewType: TabViewController>: UIViewController {

    /// The current state of the container. Set this to manually change states.
    public var state: TabViewContainerState {
        didSet {
            switch state {
            case .single:
                secondaryTabViewController = nil
                setOverrideTraitCollection(nil, forChildViewController: primaryTabViewController)
            case .split:
                let secondaryVC = TabViewType.init(theme: self.theme)
                // Override trait collection to be always compact horizontally, while in split mode
                let overriddenTraitCollection = UITraitCollection.init(traitsFrom: [
                    self.traitCollection,
                    UITraitCollection.init(horizontalSizeClass: .compact)
                ])
                setOverrideTraitCollection(overriddenTraitCollection, forChildViewController: primaryTabViewController)
                setOverrideTraitCollection(overriddenTraitCollection, forChildViewController: secondaryVC)
                self.secondaryTabViewController = secondaryVC
            }
        }
    }

    /// Current theme. When set, will propagate to current tab view controllers.
    public var theme: TabViewTheme {
        didSet { applyTheme(theme) }
    }

    /// A view displayed underneath the stack view, which has a background color set to the theme's border color.
    /// This is a relatively hacky way to display a separator when in split state.
    private let backgroundView: UIView

    /// Stack view containing visible tab view controllers.
    private let stackView: UIStackView

    /// The primary tab view controller in the container. This view controller will always be visible,
    /// no matter the state.
    public let primaryTabViewController: TabViewType

    /// The secondary tab view controller in the container. Is visible if the container is in split view.
    public private(set) var secondaryTabViewController: TabViewType? {
        didSet {
            oldValue?.view.removeFromSuperview()
            oldValue?.removeFromParentViewController()

            if let newValue = secondaryTabViewController {
                newValue.container = self
                addChildViewController(newValue)
                stackView.addArrangedSubview(newValue.view)
                newValue.didMove(toParentViewController: self)
            }
        }
    }

    /// Constraint governing the trailing position of the stack view.
    /// This is adjusted when using drag and drop, to make a drop area
    /// visible to enter split mode.
    private var stackViewRightConstraint: NSLayoutConstraint?

    /// A UIView that is used for drag and drop.
    private let dropView = TabViewContainerDropView()

    /// Create a new tab view container view controller with the given theme
    /// This creates a tab view controller of the given type.
    /// The container starts in the `single` style.
    public init(theme: TabViewTheme) {
        self.state = .single
        self.theme = theme
        self.primaryTabViewController = TabViewType.init(theme: theme)
        self.secondaryTabViewController = nil
        self.stackView = UIStackView()
        self.backgroundView = UIView()
        super.init(nibName: nil, bundle: nil)

        dropView.container = self
        primaryTabViewController.container = self
        addChildViewController(primaryTabViewController)
    }

    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    open override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView.frame = stackView.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.addSubview(backgroundView)

        // Stack view fills frame
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        let trailingConstraint = stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        self.stackViewRightConstraint = trailingConstraint
        NSLayoutConstraint.activate([
            trailingConstraint,
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 0.5
        stackView.insertArrangedSubview(primaryTabViewController.view, at: 0)
        primaryTabViewController.didMove(toParentViewController: self)

        applyTheme(theme)
    }

    private func applyTheme(_ theme: TabViewTheme) {
        view.backgroundColor = theme.barTintColor

        backgroundView.backgroundColor = theme.separatorColor
        setNeedsStatusBarAppearanceUpdate()

        primaryTabViewController.theme = theme
        secondaryTabViewController?.theme = theme
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }
    
}

/// This transparent view is displayed on the trailing side of the container, only when a drag and drop session is active.
/// It is the droppable region that a tab can be dropped into.
class TabViewContainerDropView: UIView, UIDropInteractionDelegate {

    /// Reference to the container view controller
    weak var container: TabViewContainer?

    init() {
        super.init(frame: .zero)

        let dropInteraction = UIDropInteraction(delegate: self)
        addInteraction(dropInteraction)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // Only handle tabs
    public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        guard let localSession = session.localDragSession, let localObject = localSession.items.first?.localObject else { return false }
        let canHandle = localObject is UIViewController
        return canHandle
    }

    // When the finger enters our view, move the stack view away
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        container?.contentViewRightInset = 140
    }

    // When finger leaves, reset stack view.
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        container?.contentViewRightInset = 0
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
        container?.contentViewRightInset = 0
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal.init(operation: .move)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        guard
            let container = self.container,
            let dragItem = session.localDragSession?.items.first,
            let viewController = dragItem.localObject as? UIViewController
        else { return }

        // Move the dropped view controller into a new secondary tab view controller.
        container.contentViewRightInset = 0
        container.state = .split
        container.primaryTabViewController.closeTab(viewController)
        container.secondaryTabViewController?.viewControllers = [viewController]
    }
}

/// Conform to the TabViewContainer protocol, which other objects (such as TabViewContainerDropView and TabViewController) talk to.
extension TabViewContainerViewController: TabViewContainer {

    var contentViewRightInset: CGFloat {
        get { return -(stackViewRightConstraint?.constant ?? 0) }
        set {
            stackViewRightConstraint?.constant = -newValue
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    var primaryTabViewController: TabViewController {
        return primaryTabViewController
    }

    var secondaryTabViewController: TabViewController? {
        return secondaryTabViewController
    }

    func dragStateChanged(in tabViewController: TabViewController, to newDragState: Bool) {
        // If the given tab is the primary, there is no secondary, and started dragging, then show the drop view.
        // Otherwise, remove the drop view.
        if shouldEnableDropView && newDragState == true && state == .single && tabViewController == primaryTabViewController {
            dropView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(dropView)
            NSLayoutConstraint.activate([
                dropView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                dropView.topAnchor.constraint(equalTo: view.topAnchor),
                dropView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                dropView.widthAnchor.constraint(equalToConstant: 100)
            ])
        } else {
            dropView.removeFromSuperview()
        }
    }

    private var shouldEnableDropView: Bool {
        return self.traitCollection.horizontalSizeClass == .regular
    }
}
