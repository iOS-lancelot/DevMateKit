//
//  AppDelegate.swift
//  SwiftExample
//
//  Created by Dmytro Tretiakov on 6/10/15.
//  Copyright (c) 2015 DevMate Inc. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, DevMateKitDelegate
{

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        // Send launch report
        DevMateKit.sendTrackingReport(nil, delegate: self)
        
        // Setup crash/exception reporter
        DevMateKit.setupIssuesController(self, reportingUnhandledIssues: true)
        
        // Setup trial
        var error: Int = DMKevlarError.testError.rawValue
        if !_my_secret_activation_check!(&error).boolValue || DMKevlarError.noError != DMKevlarError(rawValue: error)
        {
            DevMateKit.setupTimeTrial(self, withTimeInterval: kDMTrialWeek)
        }
    }

    @IBAction func openFeedbackWindow(_ sender: AnyObject?)
    {
        DevMateKit.showFeedbackDialog(self, in: DMFeedbackMode.sheetMode)
    }
    
    @IBAction func tryException(_ sender: AnyObject?)
    {
        print("Will throw exception now...")
        print("\(NSArray().object(at: 23))")
    }
    
    @IBAction func checkForUpdates(_ sender: AnyObject?)
    {
        DM_SUUpdater.shared().checkForUpdates(sender)
    }
    
    @IBAction func activateApp(_ sender: AnyObject?)
    {
        // Use next keys to activate current app:
        // id661692763632odr
        // id875021488172odr
        // id912199957389odr
        // id447048439877odr
        // id878451030189odr
        // id401703394809odr
        var error: Int = DMKevlarError.testError.rawValue
        if !_my_secret_activation_check!(&error).boolValue || DMKevlarError.noError != DMKevlarError(rawValue: error)
        {
            DevMateKit.runActivationDialog(self, in: DMActivationMode.sheet)
        }
        else
        {
            let license = _my_secret_license_info_getter()?.takeUnretainedValue() as! NSDictionary
            let licenseSheet = NSAlert()
            licenseSheet.messageText = "Your application is already activated."
            licenseSheet.informativeText = "\(license.description)"
            licenseSheet.addButton(withTitle: "OK")
            licenseSheet.addButton(withTitle: "Invalidate License")
            licenseSheet.beginSheetModal(for: self.window, completionHandler: { (response) -> Void in
                if response == NSAlertSecondButtonReturn
                {
                    InvalidateAppLicense()
                }
            })
        }
    }
    
    // --------------------------------------------------------------------------------------------
    // DevMateKitDelegate implementation
    @objc func trackingReporter(_ reporter: DMTrackingReporter!, didFinishSendingReportWithSuccess success: Bool) {
        let resultStr = success ? "was successfully sent" : "was failled"
        print("Tracking report \(resultStr).")
    }
    
    @objc func feedbackController(_ controller: DMFeedbackController!, parentWindowFor mode: DMFeedbackMode) -> NSWindow?
    {
        return self.window
    }

    @objc func activationController(_ controller: DMActivationController!, parentWindowFor mode: DMActivationMode) -> NSWindow?
    {
        return self.window
    }

    @objc func activationController(_ controller: DMActivationController!, shouldShowDialogFor reason: DMShowDialogReason, withAdditionalInfo additionalInfo: [AnyHashable : Any]!, proposedActivationMode ioProposedMode: UnsafeMutablePointer<DMActivationMode>!, completionHandlerSetter handlerSetter: ((DMCompletionHandler?) -> Void)!) -> Bool {
        ioProposedMode.pointee = DMActivationMode.sheet
        handlerSetter({ result in
            print("Controller end result: \(result.description)")
        })
        return true
    }
    
}

