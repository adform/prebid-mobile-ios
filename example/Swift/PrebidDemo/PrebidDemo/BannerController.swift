/*   Copyright 2018-2019 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

import PrebidMobile

import GoogleMobileAds

import MoPub

import AdformAdvertising

class BannerController: UIViewController, GADBannerViewDelegate, MPAdViewDelegate {
    
   @IBOutlet var appBannerView: UIView!
    
    @IBOutlet var adServerLabel: UILabel!
    
    var adServerName:String = ""
    
    let request = DFPRequest()
    
    var dfpBanner: DFPBannerView!
    
    var mopubBanner: MPAdView?

    var adInline: AFAdInline?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adServerLabel.text = adServerName
        
        Prebid.shared.prebidServerAccountId = "bfa84af2-bd16-4d35-96ad-31c6bb888df0"
        //Prebid.shared.prebidServerAccountId = "12345"
        Prebid.shared.shareGeoLocation = true
        
        
        let bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        bannerUnit.setAutoRefreshMillis(time: 35000)

        print("entered \(adServerName) loop" )
        if(adServerName == "DFP"){
            loadDFPBanner(bannerUnit: bannerUnit)
        } else if (adServerName == "MoPub"){
            loadMoPubBanner(bannerUnit: bannerUnit)
        } else if adServerName == "Adform" {
            loadAdformBanner(bannerUnit: bannerUnit)
        }
    }
    
    func loadDFPBanner(bannerUnit : AdUnit){
        print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")
        dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = "/19968336/PrebidMobileValidator_Banner_All_Sizes"
        dfpBanner.rootViewController = self
        dfpBanner.delegate = self
        dfpBanner.backgroundColor = .red
        appBannerView.addSubview(dfpBanner)
        request.testDevices = [ kGADSimulatorID,"cc7ca766f86b43ab6cdc92bed424069b"]
    
        bannerUnit.fetchDemand(adObject:self.request) { (ResultCode) in
            print("Prebid demand fetch for DFP \(ResultCode.name())")
            self.dfpBanner!.load(self.request)
        }
    }
    
    func loadMoPubBanner(bannerUnit: AdUnit){
        
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: "a935eac11acd416f92640411234fbba6")
        sdkConfig.globalMediationSettings = []
        
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {
            
        }
        
        mopubBanner = MPAdView(adUnitId: "a935eac11acd416f92640411234fbba6", size: CGSize(width: 300, height: 250))
        mopubBanner!.delegate = self
        
        appBannerView.addSubview(mopubBanner!)
        
        // Do any additional setup after loading the view, typically from a nib.
        bannerUnit.fetchDemand(adObject: mopubBanner!){ (ResultCode) in
            print("Prebid demand fetch for mopub \(ResultCode)")
            
            self.mopubBanner!.loadAd()
        }
        
    }

    func loadAdformBanner(bannerUnit: AdUnit) {
        print("Adform Advertising SDK version: \(AdformSDK.sdkVersion())")
        let adInline = AFAdInline(masterTagId: 557409, presenting: self, adSize: CGSize(width: 300, height: 250))
        adInline.delegate = self
        self.adInline = adInline
        adInline.backgroundColor = UIColor.yellow
        appBannerView.addSubview(adInline)

        bannerUnit.fetchDemand(adObject: adInline) { (resultCode) in
            print("Prebid demand fetch for adform \(resultCode)")

            adInline.loadAd()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func adViewDidReceiveAd(_ bannerView: DFPBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: DFPBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func viewControllerForPresentingModalView() -> UIViewController! {
        return self
    }
    
    



}

extension BannerController: AFAdInlineDelegate {

    func adInlineDidLoadAd(_ adInline: AFAdInline) {
        print("adViewDidReceiveAd")
    }

    func adInlineDidFail(toLoadAd adInline: AFAdInline, withError error: Error) {
        print("adView:didFailToReceiveAdWithError: \(error)")
    }

}
