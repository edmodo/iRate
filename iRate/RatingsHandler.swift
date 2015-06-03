//
//  RatingsHandler.swift
//  Parents
//
//  Created by Yousra Kamoona on 6/1/15.
//  Copyright (c) 2015 Edmodo. All rights reserved.
//

import Foundation

#if EDMIXPANEL
    import EDMixpanel
#endif

public class RatingsHandler : NSObject
{
    static let sharedInstance = RatingsHandler()

    var shouldAllowEventLogging:Bool = false
    
    private override init()
    {
        super.init()
    }
    
    public func setup(shouldAllowRatings:Bool, numOfEvents:UInt, andMessageTitle:String)
    {
        if (shouldAllowRatings)
        {
            self.shouldAllowEventLogging = true
            self.configureiRate(numOfEvents, messageTitle:andMessageTitle)
        }
    }
    
    private func configureiRate(eventCount:UInt, messageTitle:String)
    {
        //configure iRate
        iRate.sharedInstance().eventsUntilPrompt = eventCount
        iRate.sharedInstance().daysUntilPrompt = 0
        iRate.sharedInstance().usesUntilPrompt = 10
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
    
    public func logEvent()
    {
        if (shouldAllowEventLogging)
        {
            //increment events count and prompt rating alert if all criteria are met
            //cretieria: 2 replies or detail view taps or a combination of the 2.
            iRate.sharedInstance().logEvent(false)
        }
    }
}

extension RatingsHandler : iRateDelegate
{
    public func iRateDidPromptForRating()
    {
        EDMixpanel.sharedInstance.trackEvent("rate-app_view", params:[String : AnyObject]())
    }
    
    public func iRateUserDidAttemptToRateApp()
    {
        EDMixpanel.sharedInstance.trackEvent("rate-app_rate-click", params:[String : AnyObject]())
    }
    
    public func iRateUserDidDeclineToRateApp()
    {
        EDMixpanel.sharedInstance.trackEvent("rate-app_no-click", params:[String : AnyObject]())
    }
    
    public func iRateUserDidRequestReminderToRateApp()
    {
        EDMixpanel.sharedInstance.trackEvent("rate-app_remind-click", params:[String : AnyObject]())
    }
}
