//
//  MainMenuViewController.swift
//  Soundscape
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import UIKit
import SafariServices

enum MenuItem {
    case home, donate,  recreation, devices, help, settings, status, feedback, rate, share, testVerticalAudio, testDownAudio
    
    var localizedString: String {
        switch self {
        case .home:       return GDLocalizedString("ui.menu.close")
        case .donate:     return GDLocalizedString("menu.donate")
        case .recreation: return GDLocalizedString("menu.events")
        case .devices:    return GDLocalizedString("menu.devices")
        case .help:       return GDLocalizedString("menu.help_and_tutorials")
        case .settings:   return GDLocalizedString("settings.screen_title")
        case .status:     return GDLocalizedString("settings.section.troubleshooting")
        case .feedback:   return GDLocalizedString("menu.send_feedback")
        case .rate:       return GDLocalizedString("menu.rate")
        case .share:      return GDLocalizedString("share.title")
        case .testVerticalAudio: return "Test Vertical Audio"
        case .testDownAudio: return "Test Down Audio"
        }
    }
    
    var accessibilityString: String {
        switch self {
        case .home:       return GDLocalizedString("ui.menu.close")
        case .donate:     return GDLocalizedString("menu.donate")
        case .recreation: return GDLocalizedString("menu.events")
        case .devices:    return GDLocalizedString("menu.devices")
        case .help:       return GDLocalizedString("menu.help_and_tutorials")
        case .settings:   return GDLocalizedString("settings.screen_title")
        case .status:     return GDLocalizedString("settings.section.troubleshooting")
        case .feedback:   return GDLocalizedString("menu.send_feedback")
        case .rate:       return GDLocalizedString("menu.rate")
        case .share:      return GDLocalizedString("share.title")
        case .testVerticalAudio: return "Test Vertical Audio"
        case .testDownAudio: return "Test Down Audio"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .home:       return UIImage(named: "ic_chevron_left_28px")
        case .donate:    return UIImage(systemName: "dollarsign.circle")
        case .recreation: return UIImage(named: "nordic_walking_white_28dp")
        case .devices:    return UIImage(named: "baseline-headset-28px")
        case .help:       return UIImage(named: "ic_help_outline_28px")
        case .settings:   return UIImage(named: "ic_settings_28px")
        case .status:     return UIImage(named: "ic_build_28px")
        case .feedback:   return UIImage(named: "ic_email_28px")
        case .rate:       return UIImage(named: "ic_star_rate_28px")
        case .share:      return UIImage(systemName: "square.and.arrow.up")
        case .testVerticalAudio: return UIImage(systemName: "arrow.up.and.down.circle")
        case .testDownAudio: return UIImage(systemName: "arrow.down.circle")
        }
    }
}

class MenuViewController: UIViewController {
    
    private(set) var selected: MenuItem = .home
    
    private let menuView = MenuView()
    
    private var currentQueuePlayerID: UUID?
    
    override func loadView() {
        // Build views for menu items
        menuView.addMenuItem(.donate)
        menuView.addMenuItem(.devices)
        menuView.addMenuItem(.recreation)
        menuView.addMenuItem(.settings)
        menuView.addMenuItem(.help)
        menuView.addMenuItem(.feedback)
        menuView.addMenuItem(.rate)
        menuView.addMenuItem(.share)
        menuView.addMenuItem(.testVerticalAudio)
        menuView.addMenuItem(.testDownAudio)
        
        // Attach a listener for button taps on each menu item
        for item in menuView.items {
            item.button.addTarget(self, action: #selector(onMenuItemTouchUpInside(_:)), for: .touchUpInside)
        }
        
        menuView.topView.closeButton.accessibilityLabel = MenuItem.home.accessibilityString
        menuView.topView.closeButton.addTarget(self, action: #selector(onCloseMenuTouchUpInside), for: .touchUpInside)
        
        menuView.backgroundOverlay.addTarget(self, action: #selector(onCloseMenuTouchUpInside), for: .touchUpInside)
        menuView.crosscheckButton.addTarget(self, action: #selector(onCrosscheckTouchUpInside), for: .touchUpInside)
        
        // Set the view
        view = menuView
    }
    
    private func select(_ menuItem: MenuItem?) {
        if let item = menuItem {
            selected = item
        }
        
        closeMenu()
    }
    
    private func closeMenu(completion: (() -> Void)? = nil) {
        dismiss(animated: true, completion: completion)
    }
    
    override func accessibilityPerformEscape() -> Bool {
        select(.home)
        return true
    }
    
    @objc func onMenuItemTouchUpInside(_ sender: UIButton) {
        guard let itemView = sender.superview as? DynamicMenuItemView, let item = itemView.menuItem else {
            GDLogAppError("An unknown menu item was tapped")
            return
        }
        
        switch item {
        case .help:
            // Log this here so that we only log one "help" screen view event for each time the user goes to the
            // help pages (as opposed to using viewWillAppear: in the HelpViewController which would log every time
            // the user goes to the help pages and returns from a specific help page to the list of help pages).
            GDATelemetry.trackScreenView("help")
            select(.help)
            
        case .feedback:
            let alertController = UIAlertController(email: GDLocalizationUnnecessary("community.soundscape@gmail.com"),
                                                    subject: GDLocalizedString("settings.feedback.subject"),
                                                    preferredStyle: .actionSheet) { [weak self] (mailClient) in
                if let mailClient = mailClient {
                    print("Got: \(mailClient)")
                    GDATelemetry.track("feedback.sent", with: ["mail_client": mailClient.rawValue])

                }
                self?.closeMenu()
            }
            
            show(alertController, sender: self)
            
        case .rate:
            AppReviewHelper.showWriteReviewPage()
            closeMenu()
        case .share:
            closeMenu {
                AppShareHelper.share()
            }
        case .testVerticalAudio:
            // 防止重复播放
            guard currentQueuePlayerID == nil else {
                GDLogAudioInfo("Audio is already playing")
                return
            }
            
            GDLogAudioInfo("Starting custom beacon audio test")
            
            // 获取用户当前位置
            guard let userLocation = AppContext.shared.geolocationManager.location else {
                GDLogAudioError("No user location available")
                return
            }
            
            // 创建并播放上升音频
            guard let sound = BeaconSound(UpBeacon.self, at: userLocation, isLocalized: false) else {
                GDLogAudioError("Failed to create up beacon sound")
                return
            }
            
            if let playerId = AppContext.shared.audioEngine.play(sound) {
                GDLogAudioInfo("Started playing up beacon sound")
                currentQueuePlayerID = playerId
                
                // 播放1.5秒后停止
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    AppContext.shared.audioEngine.stop(playerId)
                    GDLogAudioInfo("Stopped up beacon sound")
                    self.currentQueuePlayerID = nil
                }
            } else {
                GDLogAudioError("Failed to start playing up beacon sound")
            }
            
        case .testDownAudio:
            // 防止重复播放
            guard currentQueuePlayerID == nil else {
                GDLogAudioInfo("Audio is already playing")
                return
            }
            
            GDLogAudioInfo("Starting down beacon audio test")
            
            // 获取用户当前位置
            guard let userLocation = AppContext.shared.geolocationManager.location else {
                GDLogAudioError("No user location available")
                return
            }
            
            // 创建并播放下降音频
            guard let sound = BeaconSound(DownBeacon.self, at: userLocation, isLocalized: false) else {
                GDLogAudioError("Failed to create down beacon sound")
                return
            }
            
            if let playerId = AppContext.shared.audioEngine.play(sound) {
                GDLogAudioInfo("Started playing down beacon sound")
                currentQueuePlayerID = playerId
                
                // 播放1.5秒后停止
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    AppContext.shared.audioEngine.stop(playerId)
                    GDLogAudioInfo("Stopped down beacon sound")
                    self.currentQueuePlayerID = nil
                }
            } else {
                GDLogAudioError("Failed to start playing down beacon sound")
            }
        default:
            select(item)
        }
    }
    
    @objc func onCloseMenuTouchUpInside() {
        closeMenu()
    }
    
    @objc func onCrosscheckTouchUpInside() {
        GDLogAppInfo("Play crosscheck audio")
        AppContext.process(CheckAudioEvent())
    }
}
