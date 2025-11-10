Pod::Spec.new do |spec|
  spec.name         = 'DaroObjCBridge'
  spec.version      = '0.0.3'
  spec.summary      = 'Objective-C Bridge for Daro iOS SDK'
  spec.description  = <<-DESC
                      Objective-C compatible wrapper for Daro iOS SDK.
                      Provides native Objective-C interfaces for all Daro ad formats.
                      DESC
  spec.homepage     = 'https://github.com/delightroom/daro-objc-ios-sdk'
  spec.license      = { :type => 'Commercial', :text => 'Copyright (c) Delightroom. All rights reserved.' }
  spec.author       = { 'Delightroom' => 'dev@delightroom.co.kr' }
  spec.source       = {
    :http => "https://github.com/delightroom/daro-objc-ios-sdk/releases/download/#{spec.version}/DaroObjCBridge.xcframework.zip"
  }

  spec.platform              = :ios
  spec.ios.deployment_target = '13.0'
  spec.swift_version         = '5.0'

  spec.resource_bundles = {
    'DaroObjCBridgeResources' => ['DaroObjCBridge.xcframework/ios-arm64/DaroObjCBridge.framework/PrivacyInfo.xcprivacy']
  }

  spec.vendored_frameworks = 'DaroObjCBridge.xcframework'

  # DaroObjCBridge is a dynamic framework that links to Daro
  # We need to declare Daro as a dependency
  spec.dependency 'DaroAds', '1.1.45-beta'
end
