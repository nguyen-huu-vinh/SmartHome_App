import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @languageName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addCount.
  ///
  /// In en, this message translates to:
  /// **'Add ({count})'**
  String addCount(Object count);

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @devicesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Device} other{{count} Devices}}'**
  String devicesCount(num count);

  /// No description provided for @devicesCountText.
  ///
  /// In en, this message translates to:
  /// **'{count} Devices'**
  String devicesCountText(Object count);

  /// No description provided for @lightsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Light} other{{count} Lights}}'**
  String lightsCount(num count);

  /// No description provided for @camerasCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Camera} other{{count} Cameras}}'**
  String camerasCount(num count);

  /// No description provided for @starsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 star} other{{count} stars}}'**
  String starsCount(num count);

  /// No description provided for @removeNamed.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String removeNamed(Object name);

  /// No description provided for @removedNamed.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String removedNamed(Object name);

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOf(Object current, Object total);

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @connectedInRoom.
  ///
  /// In en, this message translates to:
  /// **'Connected · {room}'**
  String connectedInRoom(Object room);

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @poweredOn.
  ///
  /// In en, this message translates to:
  /// **'Powered On'**
  String get poweredOn;

  /// No description provided for @poweredOff.
  ///
  /// In en, this message translates to:
  /// **'Powered Off'**
  String get poweredOff;

  /// No description provided for @powerOn.
  ///
  /// In en, this message translates to:
  /// **'Power On'**
  String get powerOn;

  /// No description provided for @powerOff.
  ///
  /// In en, this message translates to:
  /// **'Power Off'**
  String get powerOff;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOn;

  /// No description provided for @turnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get turnOff;

  /// No description provided for @voltsToday.
  ///
  /// In en, this message translates to:
  /// **'{volts}V - Today'**
  String voltsToday(Object volts);

  /// No description provided for @batteryLevel.
  ///
  /// In en, this message translates to:
  /// **'Battery {level}%'**
  String batteryLevel(Object level);

  /// No description provided for @batteryCharging.
  ///
  /// In en, this message translates to:
  /// **'Battery {level}%, charging'**
  String batteryCharging(Object level);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get navRooms;

  /// No description provided for @navAddDevice.
  ///
  /// In en, this message translates to:
  /// **'Add device'**
  String get navAddDevice;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @changeHome.
  ///
  /// In en, this message translates to:
  /// **'Change home'**
  String get changeHome;

  /// No description provided for @defaultHomeName.
  ///
  /// In en, this message translates to:
  /// **'My Home'**
  String get defaultHomeName;

  /// No description provided for @searchDevices.
  ///
  /// In en, this message translates to:
  /// **'Search Devices'**
  String get searchDevices;

  /// No description provided for @voiceSearch.
  ///
  /// In en, this message translates to:
  /// **'Voice search'**
  String get voiceSearch;

  /// No description provided for @voiceSearchSoon.
  ///
  /// In en, this message translates to:
  /// **'Voice search is coming soon'**
  String get voiceSearchSoon;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevicesFound;

  /// No description provided for @addNewDevice.
  ///
  /// In en, this message translates to:
  /// **'Add New Device'**
  String get addNewDevice;

  /// No description provided for @addRoom.
  ///
  /// In en, this message translates to:
  /// **'Add Room'**
  String get addRoom;

  /// No description provided for @roomName.
  ///
  /// In en, this message translates to:
  /// **'Room Name'**
  String get roomName;

  /// No description provided for @addHome.
  ///
  /// In en, this message translates to:
  /// **'Add Home'**
  String get addHome;

  /// No description provided for @homeName.
  ///
  /// In en, this message translates to:
  /// **'Home Name'**
  String get homeName;

  /// No description provided for @manageHomes.
  ///
  /// In en, this message translates to:
  /// **'Manage Homes'**
  String get manageHomes;

  /// No description provided for @manageRoom.
  ///
  /// In en, this message translates to:
  /// **'Manage Room'**
  String get manageRoom;

  /// No description provided for @groupLights.
  ///
  /// In en, this message translates to:
  /// **'Lights & Decoration'**
  String get groupLights;

  /// No description provided for @groupLightsList.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get groupLightsList;

  /// No description provided for @groupSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get groupSecurity;

  /// No description provided for @groupEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get groupEntertainment;

  /// No description provided for @groupClimate.
  ///
  /// In en, this message translates to:
  /// **'Climate'**
  String get groupClimate;

  /// No description provided for @groupAppliances.
  ///
  /// In en, this message translates to:
  /// **'Appliances'**
  String get groupAppliances;

  /// No description provided for @groupCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get groupCleaning;

  /// No description provided for @couldntRefresh.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh. Check your connection.'**
  String get couldntRefresh;

  /// No description provided for @loadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more'**
  String get loadingMore;

  /// No description provided for @couldntLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load more'**
  String get couldntLoadMore;

  /// No description provided for @couldntTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t turn on {name}. Check your connection.'**
  String couldntTurnOn(Object name);

  /// No description provided for @couldntTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t turn off {name}. Check your connection.'**
  String couldntTurnOff(Object name);

  /// No description provided for @couldntUpdateDevices.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update devices. Check your connection.'**
  String get couldntUpdateDevices;

  /// No description provided for @couldntAddRoom.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add the room. Check your connection.'**
  String get couldntAddRoom;

  /// No description provided for @couldntRemoveRoom.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove the room. Check your connection.'**
  String get couldntRemoveRoom;

  /// No description provided for @couldntSaveHomes.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your homes. Check your connection.'**
  String get couldntSaveHomes;

  /// No description provided for @couldntAddDevices.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add the devices. Check your connection.'**
  String get couldntAddDevices;

  /// No description provided for @roomExists.
  ///
  /// In en, this message translates to:
  /// **'You already have a room named “{name}”'**
  String roomExists(Object name);

  /// No description provided for @onboarding1Before.
  ///
  /// In en, this message translates to:
  /// **'Control Your '**
  String get onboarding1Before;

  /// No description provided for @onboarding1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Uncontrolled'**
  String get onboarding1Highlight;

  /// No description provided for @onboarding1After.
  ///
  /// In en, this message translates to:
  /// **'\nDevices with Hoome'**
  String get onboarding1After;

  /// No description provided for @onboarding1Desc.
  ///
  /// In en, this message translates to:
  /// **'All New AI Home smart devices control at your fingertips'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Before.
  ///
  /// In en, this message translates to:
  /// **'Seamless '**
  String get onboarding2Before;

  /// No description provided for @onboarding2Highlight.
  ///
  /// In en, this message translates to:
  /// **'Integration'**
  String get onboarding2Highlight;

  /// No description provided for @onboarding2After.
  ///
  /// In en, this message translates to:
  /// **' for\nEvery Smart Device'**
  String get onboarding2After;

  /// No description provided for @onboarding2Desc.
  ///
  /// In en, this message translates to:
  /// **'Connect and manage all your home gadgets in one powerful app — instantly and effortlessly'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Before.
  ///
  /// In en, this message translates to:
  /// **'Smart, Secure, and '**
  String get onboarding3Before;

  /// No description provided for @onboarding3Highlight.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get onboarding3Highlight;

  /// No description provided for @onboarding3After.
  ///
  /// In en, this message translates to:
  /// **'\nin Sync'**
  String get onboarding3After;

  /// No description provided for @onboarding3Desc.
  ///
  /// In en, this message translates to:
  /// **'Experience peace of mind with real-time control, monitoring, and automation — wherever you are.'**
  String get onboarding3Desc;

  /// No description provided for @skipIntro.
  ///
  /// In en, this message translates to:
  /// **'Skip Intro'**
  String get skipIntro;

  /// No description provided for @letsGo.
  ///
  /// In en, this message translates to:
  /// **'Let’s Go ✨'**
  String get letsGo;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Hoome’s world of digital technology.'**
  String get authWelcome;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @yourEmail.
  ///
  /// In en, this message translates to:
  /// **'Your email address'**
  String get yourEmail;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create password'**
  String get createPassword;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to {email}'**
  String resetLinkSent(Object email);

  /// No description provided for @enterEmailToReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email above to reset your password'**
  String get enterEmailToReset;

  /// No description provided for @agreePrefix.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to Hoome’s '**
  String get agreePrefix;

  /// No description provided for @agreeAnd.
  ///
  /// In en, this message translates to:
  /// **' & '**
  String get agreeAnd;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get continueWithEmail;

  /// No description provided for @continueWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Continue with phone number'**
  String get continueWithPhone;

  /// No description provided for @signInAppleSoon.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple is coming soon'**
  String get signInAppleSoon;

  /// No description provided for @signInGoogleSoon.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google is coming soon'**
  String get signInGoogleSoon;

  /// No description provided for @signUpAppleSoon.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Apple is coming soon'**
  String get signUpAppleSoon;

  /// No description provided for @signUpGoogleSoon.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google is coming soon'**
  String get signUpGoogleSoon;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed'**
  String get googleSignInFailed;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get haveAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account? '**
  String get noAccount;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify That’s You'**
  String get verifyTitle;

  /// No description provided for @verifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We just sent a 6-digit verification code to your email '**
  String get verifySubtitle;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get enterCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @newCodeSent.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent to your email'**
  String get newCodeSent;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email?'**
  String get changeEmail;

  /// No description provided for @selectCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Select Country Code'**
  String get selectCountryCode;

  /// No description provided for @countryCodeChange.
  ///
  /// In en, this message translates to:
  /// **'Country code {code}, change'**
  String countryCodeChange(Object code);

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Eg, 1234567890'**
  String get phoneHint;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @removeRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeRoomTitle(Object name);

  /// No description provided for @removeRoomMessage.
  ///
  /// In en, this message translates to:
  /// **'This room will be removed from your home.'**
  String get removeRoomMessage;

  /// No description provided for @removeRoom.
  ///
  /// In en, this message translates to:
  /// **'Remove Room'**
  String get removeRoom;

  /// No description provided for @noDevicesInRoom.
  ///
  /// In en, this message translates to:
  /// **'No devices in this room yet'**
  String get noDevicesInRoom;

  /// No description provided for @temperatureUp.
  ///
  /// In en, this message translates to:
  /// **'Temperature up'**
  String get temperatureUp;

  /// No description provided for @temperatureDown.
  ///
  /// In en, this message translates to:
  /// **'Temperature down'**
  String get temperatureDown;

  /// No description provided for @temperatureDegrees.
  ///
  /// In en, this message translates to:
  /// **'Temperature {temp} degrees'**
  String temperatureDegrees(Object temp);

  /// No description provided for @onCharge.
  ///
  /// In en, this message translates to:
  /// **'On Charge'**
  String get onCharge;

  /// No description provided for @cleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get cleaning;

  /// No description provided for @idle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get idle;

  /// No description provided for @activityAlerts.
  ///
  /// In en, this message translates to:
  /// **'Activity Alerts'**
  String get activityAlerts;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @notificationDismissed.
  ///
  /// In en, this message translates to:
  /// **'Notification dismissed'**
  String get notificationDismissed;

  /// No description provided for @reconnected.
  ///
  /// In en, this message translates to:
  /// **'Re-connected successfully'**
  String get reconnected;

  /// No description provided for @reconnect.
  ///
  /// In en, this message translates to:
  /// **'Re-Connect'**
  String get reconnect;

  /// No description provided for @turnOffAfter.
  ///
  /// In en, this message translates to:
  /// **'Turn Off After'**
  String get turnOffAfter;

  /// No description provided for @turnOffAfterChange.
  ///
  /// In en, this message translates to:
  /// **'Turn off after {minutes} minutes, change'**
  String turnOffAfterChange(Object minutes);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} Min'**
  String minutesShort(Object minutes);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} Min ago'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} Hr ago'**
  String hoursAgo(Object count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} Day ago'**
  String daysAgo(Object count);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appTour.
  ///
  /// In en, this message translates to:
  /// **'App Tour'**
  String get appTour;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share this app'**
  String get shareApp;

  /// No description provided for @appLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'App link copied to clipboard'**
  String get appLinkCopied;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// No description provided for @thanksRating.
  ///
  /// In en, this message translates to:
  /// **'Thanks for rating us {stars}★'**
  String thanksRating(Object stars);

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @yourFeedback.
  ///
  /// In en, this message translates to:
  /// **'Your feedback'**
  String get yourFeedback;

  /// No description provided for @thanksFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get thanksFeedback;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @logoutRow.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutRow;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutTitle;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to log in again to control your home.'**
  String get logoutMessage;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @prefWireless.
  ///
  /// In en, this message translates to:
  /// **'Wireless Connectivity'**
  String get prefWireless;

  /// No description provided for @prefNotifications.
  ///
  /// In en, this message translates to:
  /// **'Get Notifications'**
  String get prefNotifications;

  /// No description provided for @prefSaveData.
  ///
  /// In en, this message translates to:
  /// **'Save device data'**
  String get prefSaveData;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @tourStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String tourStep(Object current, Object total);

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @tourHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your home'**
  String get tourHomeTitle;

  /// No description provided for @tourHomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the home name to switch homes or add a new one. Everything in the app follows the home you pick.'**
  String get tourHomeMessage;

  /// No description provided for @tourFeaturedTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick controls'**
  String get tourFeaturedTitle;

  /// No description provided for @tourFeaturedMessage.
  ///
  /// In en, this message translates to:
  /// **'Turn devices on or off right here. Swipe sideways for more, tap a card for details.'**
  String get tourFeaturedMessage;

  /// No description provided for @tourAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a device'**
  String get tourAddTitle;

  /// No description provided for @tourAddMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap + to scan for nearby devices and add them to your home.'**
  String get tourAddMessage;

  /// No description provided for @tourAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get tourAlertsTitle;

  /// No description provided for @tourAlertsMessage.
  ///
  /// In en, this message translates to:
  /// **'Lights left on, devices offline… Alerts and suggestions show up here.'**
  String get tourAlertsMessage;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @cameraAngle.
  ///
  /// In en, this message translates to:
  /// **'Camera angle'**
  String get cameraAngle;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @warm.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get warm;

  /// No description provided for @cool.
  ///
  /// In en, this message translates to:
  /// **'Cool'**
  String get cool;

  /// No description provided for @percentCool.
  ///
  /// In en, this message translates to:
  /// **'{percent}% cool'**
  String percentCool(Object percent);

  /// No description provided for @colorTemperature.
  ///
  /// In en, this message translates to:
  /// **'Color temperature'**
  String get colorTemperature;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours} Hr'**
  String hoursShort(Object hours);

  /// No description provided for @runTime.
  ///
  /// In en, this message translates to:
  /// **'Run time'**
  String get runTime;

  /// No description provided for @aqiValue.
  ///
  /// In en, this message translates to:
  /// **'{aqi} AQI'**
  String aqiValue(Object aqi);

  /// No description provided for @aqiGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get aqiGood;

  /// No description provided for @aqiModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get aqiModerate;

  /// No description provided for @aqiUnhealthy.
  ///
  /// In en, this message translates to:
  /// **'Unhealthy'**
  String get aqiUnhealthy;

  /// No description provided for @cameraOff.
  ///
  /// In en, this message translates to:
  /// **'Camera off'**
  String get cameraOff;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @qualityDefault.
  ///
  /// In en, this message translates to:
  /// **'Quality - Default'**
  String get qualityDefault;

  /// No description provided for @remote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get remote;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @fanSpeed.
  ///
  /// In en, this message translates to:
  /// **'Fan Speed'**
  String get fanSpeed;

  /// No description provided for @swing.
  ///
  /// In en, this message translates to:
  /// **'Swing'**
  String get swing;

  /// No description provided for @swingLeft.
  ///
  /// In en, this message translates to:
  /// **'Swing left'**
  String get swingLeft;

  /// No description provided for @swingRight.
  ///
  /// In en, this message translates to:
  /// **'Swing right'**
  String get swingRight;

  /// No description provided for @autoSwing.
  ///
  /// In en, this message translates to:
  /// **'Auto swing'**
  String get autoSwing;

  /// No description provided for @energyCtrl.
  ///
  /// In en, this message translates to:
  /// **'Energy Ctrl'**
  String get energyCtrl;

  /// No description provided for @highCooling.
  ///
  /// In en, this message translates to:
  /// **'High Cooling'**
  String get highCooling;

  /// No description provided for @acModeCool.
  ///
  /// In en, this message translates to:
  /// **'Cool'**
  String get acModeCool;

  /// No description provided for @acModeHeat.
  ///
  /// In en, this message translates to:
  /// **'Heat'**
  String get acModeHeat;

  /// No description provided for @acModeDry.
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get acModeDry;

  /// No description provided for @acModeFan.
  ///
  /// In en, this message translates to:
  /// **'Fan'**
  String get acModeFan;

  /// No description provided for @acModeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get acModeAuto;

  /// No description provided for @fanAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get fanAuto;

  /// No description provided for @fanLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get fanLow;

  /// No description provided for @fanMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get fanMedium;

  /// No description provided for @fanHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get fanHigh;

  /// No description provided for @breakShort.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get breakShort;

  /// No description provided for @breakBetweenRounds.
  ///
  /// In en, this message translates to:
  /// **'Break between rounds'**
  String get breakBetweenRounds;

  /// No description provided for @secondsLong.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds'**
  String secondsLong(Object count);

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{count} Sec'**
  String secondsShort(Object count);

  /// No description provided for @cleaningTime.
  ///
  /// In en, this message translates to:
  /// **'Cleaning time'**
  String get cleaningTime;

  /// No description provided for @minutesLong.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutesLong(Object count);

  /// No description provided for @minutesTitle.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutesTitle;

  /// No description provided for @scheduleTo.
  ///
  /// In en, this message translates to:
  /// **'Schedule To'**
  String get scheduleTo;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @noon.
  ///
  /// In en, this message translates to:
  /// **'Noon'**
  String get noon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @addDevices.
  ///
  /// In en, this message translates to:
  /// **'Add Devices'**
  String get addDevices;

  /// No description provided for @chooseDeviceType.
  ///
  /// In en, this message translates to:
  /// **'Choose a device type below. Keep your device close by to pair it quickly.'**
  String get chooseDeviceType;

  /// No description provided for @noDevicesMatch.
  ///
  /// In en, this message translates to:
  /// **'No devices match “{query}”'**
  String noDevicesMatch(Object query);

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add '**
  String get addTitle;

  /// No description provided for @pickModels.
  ///
  /// In en, this message translates to:
  /// **'Pick one or more models below. Keep your device close by to pair it quickly.'**
  String get pickModels;

  /// No description provided for @missedDevice.
  ///
  /// In en, this message translates to:
  /// **'Missed a device? '**
  String get missedDevice;

  /// No description provided for @scanNearby.
  ///
  /// In en, this message translates to:
  /// **'Scan nearby devices'**
  String get scanNearby;

  /// No description provided for @addNow.
  ///
  /// In en, this message translates to:
  /// **'Add Now'**
  String get addNow;

  /// No description provided for @searchNamed.
  ///
  /// In en, this message translates to:
  /// **'Search {name}'**
  String searchNamed(Object name);

  /// No description provided for @noModelsYet.
  ///
  /// In en, this message translates to:
  /// **'No {name} models available yet.'**
  String noModelsYet(Object name);

  /// No description provided for @noModelsMatch.
  ///
  /// In en, this message translates to:
  /// **'No models match “{query}”'**
  String noModelsMatch(Object query);

  /// No description provided for @addedToHome.
  ///
  /// In en, this message translates to:
  /// **'Added to your home'**
  String get addedToHome;

  /// No description provided for @addingToHome.
  ///
  /// In en, this message translates to:
  /// **'Adding to your home'**
  String get addingToHome;

  /// No description provided for @addingToHomeCount.
  ///
  /// In en, this message translates to:
  /// **'Adding to your home ({current}/{total})'**
  String addingToHomeCount(Object current, Object total);

  /// No description provided for @signalConnected.
  ///
  /// In en, this message translates to:
  /// **'{name} connected'**
  String signalConnected(Object name);

  /// No description provided for @signalConnecting.
  ///
  /// In en, this message translates to:
  /// **'{name} connecting'**
  String signalConnecting(Object name);

  /// No description provided for @signalWaiting.
  ///
  /// In en, this message translates to:
  /// **'{name} waiting'**
  String signalWaiting(Object name);

  /// No description provided for @manageRoomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Rooms & Devices'**
  String get manageRoomsTitle;

  /// No description provided for @manageRoomsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a room, then tick the devices that belong to it'**
  String get manageRoomsSubtitle;

  /// No description provided for @selectRoom.
  ///
  /// In en, this message translates to:
  /// **'Select Room'**
  String get selectRoom;

  /// No description provided for @assignDevices.
  ///
  /// In en, this message translates to:
  /// **'Assign devices'**
  String get assignDevices;

  /// No description provided for @noConnectedDevices.
  ///
  /// In en, this message translates to:
  /// **'No connected devices yet.'**
  String get noConnectedDevices;

  /// No description provided for @homeNumbered.
  ///
  /// In en, this message translates to:
  /// **'Home {number}'**
  String homeNumbered(Object number);

  /// No description provided for @createHome.
  ///
  /// In en, this message translates to:
  /// **'Create Home'**
  String get createHome;

  /// No description provided for @manageHomesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here you can add, update or delete your homes'**
  String get manageHomesSubtitle;

  /// No description provided for @removeHome.
  ///
  /// In en, this message translates to:
  /// **'Remove home'**
  String get removeHome;

  /// No description provided for @stopScanning.
  ///
  /// In en, this message translates to:
  /// **'Stop Scanning'**
  String get stopScanning;

  /// No description provided for @allowAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Allow and Continue'**
  String get allowAndContinue;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get addManually;

  /// No description provided for @scanRequirement.
  ///
  /// In en, this message translates to:
  /// **'Make sure you have one or more smart devices that support Wi-Fi or Bluetooth'**
  String get scanRequirement;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @foundPrefix.
  ///
  /// In en, this message translates to:
  /// **'Found '**
  String get foundPrefix;

  /// No description provided for @foundSuffix.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{ Device} other{ Devices}}'**
  String foundSuffix(num count);

  /// No description provided for @scanConnectHint.
  ///
  /// In en, this message translates to:
  /// **'Please make sure all your devices are connected to Wi-Fi or Bluetooth'**
  String get scanConnectHint;

  /// No description provided for @cantSeeDevice.
  ///
  /// In en, this message translates to:
  /// **'Can’t see your device? Please scan again'**
  String get cantSeeDevice;

  /// No description provided for @allowCheck.
  ///
  /// In en, this message translates to:
  /// **'Allow us to check nearby devices with Bluetooth or Wi-Fi'**
  String get allowCheck;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @unableToConnect.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect'**
  String get unableToConnect;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
