//
//  SettingsViewController.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 04/01/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UITableViewController {

	@IBOutlet weak var fontSizeLabel: UILabel!
	@IBOutlet weak var fontSizeStepper: UIStepper!

	@IBOutlet weak var terminalTextColorView: UIView!
	@IBOutlet weak var terminalBackgroundColorView: UIView!
    
    @IBOutlet weak var useDarkKeyboardSwitch: UISwitch!
	
	@IBOutlet weak var caretStylePicker: UISegmentedControl!
	
    override func viewDidLoad() {
		super.viewDidLoad()

	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		updateView()
	}

	func updateView() {

		let fontSize = UserDefaultsController.shared.terminalFontSize
		fontSizeStepper.value = Double(fontSize)
		fontSizeLabel.text = String(fontSize)
		fontSizeStepper.minimumValue = 8
		fontSizeStepper.maximumValue = 32

		terminalTextColorView.backgroundColor = UserDefaultsController.shared.terminalTextColor
		terminalBackgroundColorView.backgroundColor = UserDefaultsController.shared.terminalBackgroundColor

		useDarkKeyboardSwitch.isOn = UserDefaultsController.shared.useDarkKeyboard
		caretStylePicker.selectedSegmentIndex = UserDefaultsController.shared.caretStyle.rawValue
		
	}

	@IBAction func fontSizeStepperDidChange(_ sender: UIStepper) {

		let newFontSize = Int(sender.value)

		UserDefaultsController.shared.terminalFontSize = newFontSize
		fontSizeLabel.text = String(newFontSize)
		NotificationCenter.default.post(name: .appearanceDidChange, object: nil)

	}

	@IBAction func useDarkKeyboardSwitchDidChange(_ sender: UISwitch) {

		UserDefaultsController.shared.useDarkKeyboard = useDarkKeyboardSwitch.isOn

		NotificationCenter.default.post(name: .appearanceDidChange, object: nil)

	}

    @IBAction func caretStyleDidChange(_ sender: UISegmentedControl) {
		UserDefaultsController.shared.caretStyle = CaretStyle.allCases[sender.selectedSegmentIndex]
		NotificationCenter.default.post(name: .caretStyleDidChange, object: nil)
    }
	
    @IBAction func close(_ sender: UIBarButtonItem) {

		self.dismiss(animated: true, completion: nil)

	}

	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {

		let footer = view as? UITableViewHeaderFooterView
		footer?.textLabel?.textAlignment = .center

		if section == 3 {

			let version = Bundle.main.version
			let build = Bundle.main.build

			let calendar = Calendar.current
			let components = (calendar as NSCalendar).components([.day, .month, .year], from: Date())

			if let year = components.year {

				let startYear = 2018

				let copyrightText: String

				if year == startYear {

					copyrightText = "© \(startYear) Silver Fox. OpenTerm v\(version) (build \(build))"

				} else {

					copyrightText = "© \(startYear)-\(year) Silver Fox. OpenTerm v\(version) (build \(build))"

				}

				footer?.textLabel?.text = copyrightText

			}

		}

	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		switch indexPath.section {
		case 1:
			// Section 1: Appearance
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let colorPickerViewController = storyboard.instantiateViewController(withIdentifier: "ColorPickerViewController") as! ColorPickerViewController

			let setColor: (UIColor) -> Void
			switch indexPath.row {
			case 1: setColor = { UserDefaultsController.shared.terminalTextColor = $0 }
			case 2: setColor = { UserDefaultsController.shared.terminalBackgroundColor = $0 }
			default: return
			}

			colorPickerViewController.didSelectCallback = { color in

				setColor(color)

				NotificationCenter.default.post(name: .appearanceDidChange, object: nil)

			}

			navigationController?.pushViewController(colorPickerViewController, animated: true)
		case 2:
			// Section 2: Open source
			let url: String
			switch indexPath.row {
			case 0: url = "https://github.com/louisdh/terminal"
			case 1: url = "https://github.com/holzschu/ios_system"
			case 2: url = "https://github.com/louisdh/panelkit"
			case 3: url = "https://github.com/IMcD23/InputAssistant"
			default: return
			}

			if let url = URL(string: url) {
				UIApplication.shared.open((url), options: [:], completionHandler: nil)
			}
		case 3:
			// Section 3: Links
			let url: String?
			switch indexPath.row {
			case 0:
				// Donate
				url = "https://paypal.me/LouisDhauwe/"
			case 1:
				// Review on App Store
				let appId = "1323205755"
				url = "itms-apps://itunes.apple.com/us/app/terminal/id\(appId)?action=write-review"
			case 2:
				// Twitter
				url = "https://twitter.com/LouisDhauwe"
			case 3:
				// Contact Us
				url = nil

				if MFMailComposeViewController.canSendMail() {

					let mailComposeViewController = configuredMailComposeViewController()
					self.present(mailComposeViewController, animated: true, completion: nil)

				} else {

					self.showSendMailErrorAlert()

				}
			default: return
			}

			if let urlString = url, let url = URL(string: urlString) {
				UIApplication.shared.open((url), options: [:], completionHandler: nil)
			}
		default: return
		}

	}

	func configuredMailComposeViewController() -> MFMailComposeViewController {
		let mailComposerVC = MFMailComposeViewController()
		mailComposerVC.mailComposeDelegate = self

		mailComposerVC.setToRecipients(["support@silverfox.be"])

		let version = Bundle.main.version
		let build = Bundle.main.build

		mailComposerVC.setSubject("OpenTerm \(version)")

		let deviceModel = UIDevice.current.modelName
		let systemName = UIDevice.current.systemName
		let systemVersion = UIDevice.current.systemVersion

		let body = """


		----------
		App: OpenTerm \(version) (build \(build))
		Device: \(deviceModel) (\(systemName) \(systemVersion))

		"""
		mailComposerVC.setMessageBody(body, isHTML: false)

		return mailComposerVC
	}

	func showSendMailErrorAlert(_ error: NSError? = nil) {

		let errorMsg: String

		if let e = error?.localizedDescription {
			errorMsg = e
		} else {
			errorMsg = "Email could not be sent. Please check your email configuration and try again."
		}

		let alert = UIAlertController(title: "Could not send email", message: errorMsg, preferredStyle: .alert)

		alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

		self.present(alert, animated: true) { () -> Void in

			alert.view.tintColor = .defaultMainTintColor

		}

	}

}

extension SettingsViewController: MFMailComposeViewControllerDelegate {

	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)

		if result == .sent {

			let alert = UIAlertController(title: "Thanks for your feedback!", message: "We usually reply within a couple of days.", preferredStyle: .alert)

			alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

			self.present(alert, animated: true) { () -> Void in

				alert.view.tintColor = .defaultMainTintColor

			}

		}

	}

}
