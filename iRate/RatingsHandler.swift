//
//  RatingsHandler.swift
//  Parents
//
//  Created by Yousra Kamoona on 6/1/15.
//  Copyright (c) 2015 Edmodo. All rights reserved.
//

import Foundation
import EDMPlatform
import EDMixpanel
import MessageUI

enum RatingsKey : String
{
    case ShouldBlockPromptOnLaunch = "ShouldBlockPromptOnLaunch"
    case NumOfUses = "NumOfUsesSince-v1.6.0"
}

public class RatingsHandler : NSObject
{
    static let sharedInstance = RatingsHandler()
    
    let useCountForRatingsPrompt: Int = 3

    private override init()
    {
        super.init()
    }
    
    public func setup(shouldAllowRatings:Bool, messageTitle:String)
    {
        if (shouldAllowRatings)
        {
            self.configureiRate(messageTitle)
        }
    }
    
    private func configureiRate(messageTitle:String)
    {
        //configure iRate
        iRate.sharedInstance().eventsUntilPrompt = 0
        iRate.sharedInstance().usesUntilPrompt = 0 // total num of launches since installation
        iRate.sharedInstance().daysUntilPrompt = 0 // TESTING THIS
        iRate.sharedInstance().remindPeriod = 7
        iRate.sharedInstance().promptAtLaunch = false
        
        iRate.sharedInstance().delegate = self

        if (debugBuild)
        {
           iRate.sharedInstance().onlyPromptIfLatestVersion = false
        }
        
        //overriding the default iRate strings
        iRate.sharedInstance().messageTitle = NSLocalizedString(messageTitle, comment: "iRate message title")
        iRate.sharedInstance().message = NSLocalizedString("Rate it now in the App Store!", comment: "iRate message")
        iRate.sharedInstance().cancelButtonLabel = NSLocalizedString("No Thanks", comment: "iRate decline button")
        iRate.sharedInstance().remindButtonLabel = NSLocalizedString("Remind Me Later", comment: "iRate remind button")
        iRate.sharedInstance().rateButtonLabel = NSLocalizedString("Rate Now", comment: "iRate accept button")
    }
}

// MARK: - Ratings Pre-Prompt Alerts
extension RatingsHandler
{
    internal func ratingsPrePromptAlert(yesActionBlock:((action: UIAlertAction) -> Void)? = nil,
                                        noActionBlock:((action: UIAlertAction) -> Void)? = nil) -> UIAlertController
    {
        let message = NSLocalizedString("Do you like our App?", comment: "Do you like our App?")
        
        let alertController = UIAlertController.alertWithPrompt(
            nil,
            message: message,
            yesActionBlock:
            {(action) in
                iRate.sharedInstance().promptIfNetworkAvailable()
                
                if let yesBlock = yesActionBlock
                { yesBlock(action: action) }
            },
            noActionBlock:
            {(action) in
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: RatingsKey.ShouldBlockPromptOnLaunch.rawValue)
                
                if let noBlock = noActionBlock
                { noBlock(action: action) }
            }
        )
        
        return alertController
    }
    
    internal func helpUsImproveAlert(yesActionBlock:((action: UIAlertAction) -> Void)? = nil,
                                     noActionBlock:((action: UIAlertAction) -> Void)? = nil) -> UIAlertController
    {
        let message = NSLocalizedString("Would you like to help us improve?", comment: "Would you like to help us improve?")
        let yesTitle = NSLocalizedString("Sure", comment: "Sure")
        
        let alertController = UIAlertController.alertWithPrompt(
            nil, message: message,
            yesTitle: yesTitle,
            yesActionBlock:
            { (action) in
                if let yesBlock = yesActionBlock
                { yesBlock(action: action) }
            },
            noActionBlock:
            { (action) in
                if let noBlock = noActionBlock
                { noBlock(action: action) }
            }
        )
        
        return alertController
    }
    
    internal func populateSupportEmail() -> MFMailComposeViewController
    {
        let mailController = MFMailComposeViewController.init()
        if MFMailComposeViewController.canSendMail()
        {
            let currentUser = Platform.sharedInstance.currentUser
            
            let mailSubject = NSLocalizedString("Improve Parents App - iOS", comment: "Improve Parents App - iOS")
            let recipientEmail = NSLocalizedString("support@edmodo.com", comment: "support@edmodo.com")
            let messageBody = NSLocalizedString("Hello Edmodo Staff,\n Here are a few things I think will make the Parents App better:\n", comment: "Help us improve email body")
            
            mailController.setToRecipients([recipientEmail])
            mailController.setSubject("\(mailSubject) (uid:\(currentUser?.ID.nonUniqueIdentifier))")
            mailController.setMessageBody(messageBody, isHTML: false)
        }
        
        return mailController
    }
}

extension RatingsHandler : iRateDelegate
{
    public func iRateDidPromptForRating()
    {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: RatingsKey.ShouldBlockPromptOnLaunch.rawValue)
        EDMixpanel.sharedInstance.trackEvent("rate-app_view", params:[String : AnyObject]())
    }
    
    public func iRateUserDidAttemptToRateApp()
    {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: RatingsKey.ShouldBlockPromptOnLaunch.rawValue)
        EDMixpanel.sharedInstance.trackEvent("rate-app_rate-click", params:[String : AnyObject]())
    }
    
    public func iRateUserDidDeclineToRateApp()
    {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: RatingsKey.ShouldBlockPromptOnLaunch.rawValue)
        EDMixpanel.sharedInstance.trackEvent("rate-app_no-click", params:[String : AnyObject]())
    }
    
    public func iRateUserDidRequestReminderToRateApp()
    {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: RatingsKey.ShouldBlockPromptOnLaunch.rawValue)
        EDMixpanel.sharedInstance.trackEvent("rate-app_remind-click", params:[String : AnyObject]())
    }
}
