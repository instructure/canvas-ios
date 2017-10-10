package com.teacher;

import android.app.Application;

import com.facebook.react.ReactApplication;
import com.lwansbrough.RCTCamera.RCTCameraPackage;
import com.zmxv.RNSound.RNSoundPackage;
import com.BV.LinearGradient.LinearGradientPackage;
import com.rnim.rn.audio.ReactNativeAudioPackage;
import com.reactnativedocumentpicker.ReactNativeDocumentPicker;
import com.chirag.RNMail.RNMail;
import com.rnfs.RNFSPackage;
import com.reactnativenavigation.NavigationReactPackage;
import com.imagepicker.ImagePickerPackage;
import com.wix.interactable.Interactable;
import com.cmcewen.blurview.BlurViewPackage;
import com.learnium.RNDeviceInfo.RNDeviceInfo;
import com.reactnativenavigation.NavigationReactPackage;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;

import java.util.Arrays;
import java.util.List;

public class MainApplication extends Application implements ReactApplication {

  private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
    @Override
    public boolean getUseDeveloperSupport() {
      return BuildConfig.DEBUG;
    }

    @Override
    protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
          new MainReactPackage(),
            new RCTCameraPackage(),
            new RNSoundPackage(),
            new LinearGradientPackage(),
            new ReactNativeAudioPackage(),
            new ReactNativeDocumentPicker(),
            new RNMail(),
            new RNFSPackage(),
            new NavigationReactPackage(),
            new ImagePickerPackage(),
            new Interactable(),
            new BlurViewPackage(),
            new RNDeviceInfo()
            new NavigationReactPackage()
      );
    }

    @Override
    protected String getJSMainModuleName() {
      return "index";
    }
  };

  @Override
  public ReactNativeHost getReactNativeHost() {
    return mReactNativeHost;
  }

  @Override
  public void onCreate() {
    super.onCreate();
    SoLoader.init(this, /* native exopackage */ false);
  }
}
