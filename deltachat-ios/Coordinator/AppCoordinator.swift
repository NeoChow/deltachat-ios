//
//  AppCoordinator.swift
//  deltachat-ios
//
//  Created by Jonas Reinsch on 07.11.17.
//  Copyright © 2017 Jonas Reinsch. All rights reserved.
//

import UIKit

class AppCoordinator: NSObject, Coordinator, UITabBarControllerDelegate {
	private let window: UIWindow

	var rootViewController: UIViewController {
		return tabBarController
	}

	private var childCoordinators: [Coordinator] = []

	private lazy var tabBarController: UITabBarController = {
		let tabBarController = UITabBarController()
		tabBarController.viewControllers = [contactListController, mailboxController, profileController, chatListController, settingsController]
		// put viewControllers here
		tabBarController.delegate = self
		tabBarController.tabBar.tintColor = DCColors.primary
		// tabBarController.tabBar.isTranslucent = false
		return tabBarController
	}()

	// MARK: viewControllers

	private lazy var contactListController: UIViewController = {
		let controller = ContactListController()
		let nav = NavigationController(rootViewController: controller)
		let settingsImage = UIImage(named: "contacts")
		nav.tabBarItem = UITabBarItem(title: "Contacts", image: settingsImage, tag: 4)
		let coordinator = ContactListCoordinator(navigationController: nav)
		self.childCoordinators.append(coordinator)
		controller.coordinator = coordinator
		return nav
	}()

	private lazy var mailboxController: UIViewController = {
		let controller = MailboxViewController(chatId: Int(DC_CHAT_ID_DEADDROP), title: "Mailbox")
		controller.disableWriting = true
		let nav = NavigationController(rootViewController: controller)
		let settingsImage = UIImage(named: "message")
		nav.tabBarItem = UITabBarItem(title: "Mailbox", image: settingsImage, tag: 4)
		let coordinator = MailboxCoordinator(navigationController: nav)
		self.childCoordinators.append(coordinator)
		controller.coordinator = coordinator
		return nav
	}()

	private lazy var profileController: UIViewController = {
		let controller = ProfileViewController()
		let nav = NavigationController(rootViewController: controller)
		let settingsImage = UIImage(named: "report_card")
		nav.tabBarItem = UITabBarItem(title: "My Profile", image: settingsImage, tag: 4)
		let coordinator = ProfileCoordinator(rootViewController: nav)
		self.childCoordinators.append(coordinator)
		controller.coordinator = coordinator
		return nav
	}()

	private lazy var chatListController: UIViewController = {
		let controller = ChatListController()
		let nav = NavigationController(rootViewController: controller)
		let settingsImage = UIImage(named: "chat")
		nav.tabBarItem = UITabBarItem(title: "Chats", image: settingsImage, tag: 4)
		let coordinator = ChatListCoordinator(navigationController: nav)
		self.childCoordinators.append(coordinator)
		controller.coordinator = coordinator
		return nav
	}()

	private lazy var settingsController: UIViewController = {
		let controller = SettingsViewController()
		let nav = NavigationController(rootViewController: controller)
		let settingsImage = UIImage(named: "settings")
		nav.tabBarItem = UITabBarItem(title: "Settings", image: settingsImage, tag: 4)
		let coordinator = SettingsCoordinator(navigationController: nav)
		self.childCoordinators.append(coordinator)
		controller.coordinator = coordinator
		return nav
	}()

	init(window: UIWindow) {
		self.window = window
		super.init()
		window.rootViewController = rootViewController
		window.makeKeyAndVisible()
	}

	public func start() {
		showTab(index: 3)
	}

	func showTab(index: Int) {
		tabBarController.selectedIndex = index
	}

	func presentLoginController() {
		let accountSetupController = AccountSetupController()
		let accountSetupNavigationController = UINavigationController(rootViewController: accountSetupController)
		rootViewController.present(accountSetupNavigationController, animated: false, completion: nil)
	}
}

extension AppCoordinator: UITabBarDelegate {
	func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		print("item selected")
	}

	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		print("shouldSelect")
		return true 
	}
}

class ContactListCoordinator: Coordinator {
	let navigationController: UINavigationController

	var childCoordinators: [Coordinator] = []

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func showContactDetail(contactId: Int) {
		let contactDetailController = ContactDetailViewController(contactId: contactId)
		let coordinator = ContactDetailCoordinator(navigationController: navigationController)
		childCoordinators.append(coordinator)
		contactDetailController.coordinator = coordinator
		navigationController.pushViewController(contactDetailController, animated: true)
	}
}

// since mailbox and chatView -tab both use ChatViewController we want to be able to assign different functionality via coordinators -> therefore we override unneeded functions such as showChatDetail -> maybe find better solution in longterm
class MailboxCoordinator: ChatViewCoordinator {
	override func showChatDetail(chatId _: Int) {
		// ignore for now
	}
}

class ProfileCoordinator: Coordinator {
	var rootViewController: UIViewController

	init(rootViewController: UIViewController) {
		self.rootViewController = rootViewController
	}
}

class ChatListCoordinator: Coordinator {
	let navigationController: UINavigationController

	var childCoordinators: [Coordinator] = []

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func showNewChatController() {
		let newChatVC = NewChatViewController()
		let coordinator = NewChatCoordinator(navigationController: navigationController)
		childCoordinators.append(coordinator)
		newChatVC.coordinator = coordinator
		navigationController.pushViewController(newChatVC, animated: true)
	}

	func showChat(chatId: Int) {
		let chatVC = ChatViewController(chatId: chatId)
		let coordinator = ChatViewCoordinator(navigationController: navigationController)
		childCoordinators.append(coordinator)
		chatVC.coordinator = coordinator
		navigationController.pushViewController(chatVC, animated: true)
	}
}

class SettingsCoordinator: Coordinator {
	let navigationController: UINavigationController

	var childCoordinators:[Coordinator] = []

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func showAccountSetupController() {
		let accountSetupVC = AccountSetupController()
		let coordinator = AccountSetupCoordinator(navigationController: navigationController)
		childCoordinators.append(coordinator)
		accountSetupVC.coordinator = coordinator
		navigationController.pushViewController(accountSetupVC, animated: true)
	}

	func showEditSettingsController(option: SettingsEditOption) {
		let editController = EditSettingsController()
		editController.activateField(option: option)
		navigationController.pushViewController(editController, animated: true)
	}
}

class AccountSetupCoordinator: Coordinator {
	let navigationController: UINavigationController

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func showImapPortOptions() {
		let currentMailPort = MRConfig.mailPort ?? MRConfig.configuredMailPort
		let currentPort = Int(currentMailPort)
		let portSettingsController = PortSettingsController(sectionTitle: "IMAP Port", ports: [143, 993], currentPort: currentPort)
		portSettingsController.onDismiss = {
			port in
			MRConfig.mailPort = port
			dc_configure(mailboxPointer)
		}
		navigationController.pushViewController(portSettingsController, animated: true)
	}

	func showImapSecurityOptions() {
		let currentSecurityOption = MRConfig.getImapSecurity()
		let convertedOption = SecurityConverter.convertHexToString(type: .IMAPSecurity, hex: currentSecurityOption)
		let securitySettingsController = SecuritySettingsController(title: "IMAP Security", options: ["Automatic", "SSL / TLS", "STARTTLS", "OFF"], selectedOption: convertedOption)
		securitySettingsController.onDismiss = {
			option in
			if let secValue = SecurityValue(rawValue: option) {
				let value = SecurityConverter.convertValueToInt(type: .IMAPSecurity, value: secValue)
				MRConfig.setImapSecurity(imapFlags: value)
				dc_configure(mailboxPointer)
			}
		}
		navigationController.pushViewController(securitySettingsController, animated: true)
	}

	func showSmtpPortsOptions() {
		let currentMailPort = MRConfig.sendPort ?? MRConfig.configuredSendPort
		let currentPort = Int(currentMailPort)
		let portSettingsController = PortSettingsController(sectionTitle: "SMTP Port", ports: [25, 465, 587], currentPort: currentPort)
		portSettingsController.onDismiss = {
			port in
			MRConfig.sendPort = port
			dc_configure(mailboxPointer)
		}
		navigationController.pushViewController(portSettingsController, animated: true)
	}

	func showSmptpSecurityOptions() {
		let currentSecurityOption = MRConfig.getSmtpSecurity()
		let convertedOption = SecurityConverter.convertHexToString(type: .SMTPSecurity, hex: currentSecurityOption)
		let securitySettingsController = SecuritySettingsController(title: "IMAP Security", options: ["Automatic", "SSL / TLS", "STARTTLS", "OFF"], selectedOption: convertedOption)
		securitySettingsController.onDismiss = {
			option in
			if let secValue = SecurityValue(rawValue: option) {
				let value = SecurityConverter.convertValueToInt(type: .SMTPSecurity, value: secValue)
				MRConfig.setSmtpSecurity(smptpFlags: value)
				dc_configure(mailboxPointer)
			}
		}
		navigationController.pushViewController(securitySettingsController, animated: true)
	}
}

class NewChatCoordinator: Coordinator {
	let navigationController: UINavigationController

	private var childCoordinators: [Coordinator] = []

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func showNewGroupController() {
		let newGroupController = NewGroupViewController()
		let coordinator = NewGroupCoordinator(navigationController: navigationController)
		childCoordinators.append(coordinator)
		newGroupController.coordinator = coordinator
		navigationController.pushViewController(newGroupController, animated: true)
	}

	func showQRCodeController() {
		let controller = QrCodeReaderController()
		// controller.delegate = self
		// present(controller, animated: true, completion: nil)
	}

	func showNewContactController() {
		let newContactController = NewContactController()
		navigationController.pushViewController(newContactController, animated: true)
	}

	func showNewChat(contactId: Int) {
		let chatId = dc_create_chat_by_contact_id(mailboxPointer, UInt32(contactId))
		showChat(chatId: Int(chatId))
	}

	func showChat(chatId: Int) {
		let chatViewController = ChatViewController(chatId: chatId)
		let coordinator = ChatViewCoordinator(navigationController: navigationController)
		childCoordinators.append(coordinator)
		chatViewController.coordinator = coordinator
		navigationController.pushViewController(chatViewController, animated: true)
		navigationController.viewControllers.remove(at: 1)
	}
}

class ChatDetailCoordinator: Coordinator {
	let navigationController: UINavigationController

	private var childCoordinators: [Coordinator] = []

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func showSingleChatEdit(contactId: Int) {
		let newContactController = NewContactController(contactIdForUpdate: contactId)
		navigationController.pushViewController(newContactController, animated: true)
	}

	func showAddGroupMember(chatId: Int) {
		let groupMemberViewController = AddGroupMembersViewController(chatId: chatId)
		navigationController.pushViewController(groupMemberViewController, animated: true)
	}
}

class ChatViewCoordinator: Coordinator {
	let navigationController: UINavigationController

	var childCoordinators: [Coordinator] = []

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func showChatDetail(chatId: Int) {
		let chat = MRChat(id: chatId)
		let chatDetailViewController: ChatDetailViewController
		switch chat.chatType {
		case .SINGLE:
			chatDetailViewController = SingleChatDetailViewController(chatId: chatId) // inherits from ChatDetailViewController
		case .GROUP, .VERYFIEDGROUP:
			chatDetailViewController = GroupChatDetailViewController(chatId: chatId) // inherits from ChatDetailViewController
		}
		let coordinator = ChatDetailCoordinator(navigationController: navigationController)
		childCoordinators.append(coordinator)
		chatDetailViewController.coordinator = coordinator
		navigationController.pushViewController(chatDetailViewController, animated: true)
	}
}

class NewGroupCoordinator: Coordinator {
	let navigationController: UINavigationController

	private var childCoordinators: [Coordinator] = []

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func showGroupNameController(contactIdsForGroup: Set<Int>) {
		let groupNameController = GroupNameController(contactIdsForGroup: contactIdsForGroup)
		let coordinator = GroupNameCoordinator(navigationController: navigationController)
		childCoordinators.append(coordinator)
		groupNameController.coordinator = coordinator
		navigationController.pushViewController(groupNameController, animated: true)
	}
}

class GroupNameCoordinator: Coordinator {
	let navigationController: UINavigationController

	private var childCoordinators: [Coordinator] = []

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func showGroupChat(chatId: Int) {
		let chatViewController = ChatViewController(chatId: chatId)
		let coordinator = ChatViewCoordinator(navigationController: navigationController)
		childCoordinators.append(coordinator)
		chatViewController.coordinator = coordinator
		navigationController.popToRootViewController(animated: false)
		navigationController.pushViewController(chatViewController, animated: true)
	}
}

class ContactDetailCoordinator: Coordinator {
	let navigationController: UINavigationController

	private var childCoordinators: [Coordinator] = []

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func showChat(chatId: Int) {
		let chatViewController = ChatViewController(chatId: chatId)
		let coordinator = ChatViewCoordinator(navigationController: navigationController)
		childCoordinators.append(coordinator)
		chatViewController.coordinator = coordinator
		navigationController.popToRootViewController(animated: false)
		navigationController.pushViewController(chatViewController, animated: true)
	}
}
