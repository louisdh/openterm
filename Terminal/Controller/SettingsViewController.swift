//
//  SettingsViewController.swift
//  Terminal
//
//  Created by Louis D'hauwe on 04/01/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import MessageUI

extension UIDevice {
	
	public var modelName: String {
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		let identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8 , value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
		return identifier
	}
}

extension Bundle {
	
	public var version: String {
		return object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	}
	
	public var build: String {
		return object(forInfoDictionaryKey: "CFBundleVersion") as! String
	}
	
}

class SettingsViewController: UITableViewController {

    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var fontSizeStepper: UIStepper!
    
    @IBOutlet weak var terminalTextColorView: UIView!
    @IBOutlet weak var terminalBackgroundColorView: UIView!
    
    @IBOutlet weak var useDarkKeyboardSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateView()
    }
    
    func updateView() {
        
        let fontSize = UserDefaults.standard.integer(forKey: "terminalFontSize")
        fontSizeStepper.value = Double(fontSize)
        fontSizeLabel.text = String(fontSize)
        fontSizeStepper.minimumValue = 8
        fontSizeStepper.maximumValue = 32
        
        terminalTextColorView.backgroundColor = UserDefaults.standard.colorForKey(forKey: "terminalTextColor")
        terminalBackgroundColorView.backgroundColor = UserDefaults.standard.colorForKey(forKey: "terminalBackgroundColor")
        
        useDarkKeyboardSwitch.isOn = UserDefaults.standard.bool(forKey: "userDarkKeyboardInTerminal")
        
    }

    @IBAction func fontSizeStepperDidChange(_ sender: UIStepper) {
        
        UserDefaults.standard.set(sender.value, forKey: "terminalFontSize")
        fontSizeLabel.text = String(UserDefaults.standard.integer(forKey: "terminalFontSize"))
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appearanceDidChange"), object: nil)
        
    }
    
    @IBAction func useDarkKeyboardSwitchDidChange(_ sender: UISwitch) {
        
        UserDefaults.standard.set(useDarkKeyboardSwitch.isOn, forKey: "userDarkKeyboardInTerminal")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appearanceDidChange"), object: nil)
        
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
			let components = (calendar as NSCalendar).components([.day , .month , .year], from: Date())
			
			if let year = components.year {
				
				let startYear = 2018
				
				let copyrightText: String
				
				if year == startYear {
					
					copyrightText = "© \(startYear) Silver Fox. Terminal v\(version) (build \(build))"
					
				} else {
					
					copyrightText = "© \(startYear)-\(year) Silver Fox. Terminal v\(version) (build \(build))"

				}
				
				footer?.textLabel?.text = copyrightText
				
			}
			
		}
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	
		tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let colorPickerViewController = storyboard.instantiateViewController(withIdentifier: "ColorPickerViewController") as! ColorPickerViewController
            
            if indexPath.row == 1 {
                
                colorPickerViewController.delegate = UpdateTerminalTextColor()
                navigationController?.pushViewController(colorPickerViewController, animated: true)
                
            }
            
            if indexPath.row == 2 {
                
                colorPickerViewController.delegate = UpdateTerminalBackgroundColor()
                navigationController?.pushViewController(colorPickerViewController, animated: true)
                
            }
            
        }
        
		if indexPath.section == 2 {

			if indexPath.row == 0 {
				
				if let url = URL(string: "https://github.com/louisdh/terminal") {
					UIApplication.shared.open((url), options: [:], completionHandler: nil)
				}
				
			}
			
			if indexPath.row == 1 {
				
				if let url = URL(string: "https://github.com/holzschu/ios_system") {
					UIApplication.shared.open((url), options: [:], completionHandler: nil)
				}
				
			}
			
			if indexPath.row == 2 {
				
				if let url = URL(string: "https://github.com/louisdh/panelkit") {
					UIApplication.shared.open((url), options: [:], completionHandler: nil)
				}
				
			}
			
		}
		
		if indexPath.section == 3 {
			
			if indexPath.row == 0 {
				
				let appId = "1323205755"
				
				let urlString = "itms-apps://itunes.apple.com/us/app/terminal/id\(appId)?action=write-review"
				
				if let url = URL(string: urlString) {
					UIApplication.shared.open((url), options: [:], completionHandler: nil)
				}
				
			}
			
			if indexPath.row == 1 {
				
				if let url = URL(string: "https://twitter.com/LouisDhauwe") {
					UIApplication.shared.open((url), options: [:], completionHandler: nil)
				}
				
			}
			
			if indexPath.row == 2 {
				
				if MFMailComposeViewController.canSendMail() {
					
					let mailComposeViewController = configuredMailComposeViewController()
					self.present(mailComposeViewController, animated: true, completion: nil)
					
				} else {
					
					self.showSendMailErrorAlert()
					
				}
				
			}
			
			
		}
		
	}
	
	func configuredMailComposeViewController() -> MFMailComposeViewController {
		let mailComposerVC = MFMailComposeViewController()
		mailComposerVC.mailComposeDelegate = self
		
		mailComposerVC.setToRecipients(["support@silverfox.be"])
		
		let version = Bundle.main.version
		let build = Bundle.main.build
		
		mailComposerVC.setSubject("Terminal \(version)")
		
		let deviceModel = UIDevice.current.modelName
		let systemName = UIDevice.current.systemName
		let systemVersion = UIDevice.current.systemVersion
		
		let body = """
		
		
		----------
		App: Terminal \(version) (build \(build))
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
			errorMsg = "Email could not be send. Please check your email configuration and try again."
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
