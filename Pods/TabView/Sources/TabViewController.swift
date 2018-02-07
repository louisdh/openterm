//
//  TabViewController.swift
//  TabView
//
//  Created by Ian McDowell on 2/2/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit

open class TabViewController: UIViewController {

    /// The container that this tab view resides in.
    internal weak var container: TabViewContainer?

    /// Current theme
    public var theme: TabViewTheme {
        didSet { self.applyTheme(theme) }
    }

    open override var title: String? {
        get { return super.title ?? visibleViewController?.title }
        set { super.title = newValue }
    }

    /// The current tab shown in the tab view controller's content view
    public var visibleViewController: UIViewController? {
        didSet {
            oldValue?.removeFromParentViewController()
            oldValue?.view.removeFromSuperview()

            if let visibleViewController = visibleViewController {
                addChildViewController(visibleViewController)
                visibleViewController.view.frame = contentView.bounds
                contentView.addSubview(visibleViewController.view)
                visibleViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                visibleViewController.didMove(toParentViewController: self)
            }
            updateVisibleViewControllerInsets()
            
            if let visibleViewController = visibleViewController {
                visibleNavigationItemObserver = NavigationItemObserver.init(navigationItem: visibleViewController.navigationItem, { [weak self] in
                    self?.refreshTabBar()
                })
            } else {
                visibleNavigationItemObserver = nil
            }
            if let newValue = visibleViewController, let index = viewControllers.index(of: newValue) {
                tabViewBar.selectTab(atIndex: index)
            }
            refreshTabBar()
        }
    }
    private var _viewControllers: [UIViewController] = [] {
        didSet {
            displayEmptyViewIfNeeded()
        }
    }
    /// All of the tabs, in order.
    public var viewControllers: [UIViewController] {
        get { return _viewControllers }
        set {
            _viewControllers = newValue;
            tabViewBar.refresh()
            if visibleViewController == nil || !viewControllers.contains(visibleViewController!) {
                visibleViewController = viewControllers.first
            }
        }
    }

    /// If you want to display a view when there are no tabs, set this to some value
    public var emptyView: UIView? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            displayEmptyViewIfNeeded()
        }
    }

    /// Store the value of the below property.
    private var _hidesSingleTab: Bool = true
    /// Should the tab bar hide when only a single tab is visible? Default: YES
    /// If in the right side of a split container, then always NO
    public var hidesSingleTab: Bool {
        get {
            if let container = container, container.state == .split { return false }
            return _hidesSingleTab
        }
        set { _hidesSingleTab = newValue }
    }

    /// Tab bar shown above the content view
    private let tabViewBar: TabViewBar

    /// View containing the current tab's view
    private let contentView: UIView

    private var ownNavigationItemObserver: NavigationItemObserver?
    private var visibleNavigationItemObserver: NavigationItemObserver?

    internal var dragInProgress: Bool = false {
        didSet { container?.dragStateChanged(in: self, to: dragInProgress) }
    }

    /// Create a new tab view controller, with a theme.
    public required init(theme: TabViewTheme) {
        self.theme = theme
        self.tabViewBar = TabViewBar(theme: theme)
        self.contentView = UIView()

        super.init(nibName: nil, bundle: nil)

        tabViewBar.barDataSource = self
        tabViewBar.barDelegate = self

        self.ownNavigationItemObserver = NavigationItemObserver.init(navigationItem: self.navigationItem, self.refreshTabBar)
    }

    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Content view fills frame
        contentView.frame = view.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(contentView)

        // Tab bar is on top of content view, with automatic height.
        tabViewBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabViewBar)
        NSLayoutConstraint.activate([
            tabViewBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabViewBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabViewBar.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        self.edgesForExtendedLayout = []

        applyTheme(theme)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateVisibleViewControllerInsets()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Trait collection may change because of change in container states.
        // A change in state may invalidate the tab hiding behavior.
        tabViewBar.hideTabsIfNeeded()
    }

    /// Activates the given tab and saves the new state
    ///
    /// - Parameters:
    ///   - viewController: the tab to activate
    ///   - saveState: if the new state should be saved
    open func activateTab(_ tab: UIViewController) {
        if !_viewControllers.contains(tab) {
            _viewControllers.append(tab)
            tabViewBar.addTab(atIndex: _viewControllers.count - 1)
        }
        visibleViewController = tab
    }

    /// Closes the provided tab and selects another tab to be active.
    ///
    /// - Parameter tab: the tab to close
    open func closeTab(_ tab: UIViewController) {
        if let index = _viewControllers.index(of: tab) {
            _viewControllers.remove(at: index)
            tabViewBar.removeTab(atIndex: index)

            if index == 0 {
                visibleViewController = _viewControllers.first
            } else {
                visibleViewController = _viewControllers[index - 1]
            }
        }

        // If this is the secondary vc in a container, and there are none left,
        // close this vc by setting the state to single
        if _viewControllers.isEmpty, let container = container {
            if container.state == .split && container.secondaryTabViewController == self {
                container.state = .single
            }
        }
    }

    func insertTab(_ tab: UIViewController, atIndex index: Int) {
        if let oldIndex = _viewControllers.index(of: tab) {
            _viewControllers.remove(at: oldIndex)
        }
        _viewControllers.insert(tab, at: index)
        tabViewBar.addTab(atIndex: index)
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }

    /// Apply the current theme to the view controller and its views.
    private func applyTheme(_ theme: TabViewTheme) {
        self.view.backgroundColor = theme.backgroundColor
        self.setNeedsStatusBarAppearanceUpdate()
        tabViewBar.theme = theme
    }

    /// The safe area of the visible view controller is inset on top by the height of the bar.
    /// Tries to replicate behavior by UINavigationViewController.
    private func updateVisibleViewControllerInsets() {
        if let visibleViewController = visibleViewController {
            visibleViewController.additionalSafeAreaInsets = UIEdgeInsets(top: tabViewBar.frame.size.height - contentView.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
        }
    }

    /// When a navigation changes, it's important to update all of the views that we display from that item.
    private func refreshTabBar() {
        tabViewBar.updateTitles()
        tabViewBar.setLeadingBarButtonItems((navigationItem.leftBarButtonItems ?? []) + (visibleViewController?.navigationItem.leftBarButtonItems ?? []))
        tabViewBar.setTrailingBarButtonItems((visibleViewController?.navigationItem.rightBarButtonItems ?? []) + (navigationItem.rightBarButtonItems ?? []))
    }

    /// Show an empty view if there is one, and there are no view controllers
    private func displayEmptyViewIfNeeded() {
        if let emptyView = self.emptyView {
            if viewControllers.isEmpty {
                emptyView.frame = contentView.bounds
                contentView.addSubview(emptyView)
                emptyView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            } else {
                emptyView.removeFromSuperview()
            }
        }
    }
}

// Define these conformances, to make sure we expose the proper methods to the tab view bar.
extension TabViewController: TabViewBarDataSource, TabViewBarDelegate {
}
