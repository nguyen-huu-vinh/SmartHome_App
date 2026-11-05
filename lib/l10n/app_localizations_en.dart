// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageName => 'English';

  @override
  String get language => 'Language';

  @override
  String get continueLabel => 'Continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get undo => 'Undo';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get done => 'Done';

  @override
  String get remove => 'Remove';

  @override
  String get or => 'Or';

  @override
  String get more => 'More';

  @override
  String get update => 'Update';

  @override
  String get send => 'Send';

  @override
  String get submit => 'Submit';

  @override
  String get add => 'Add';

  @override
  String addCount(Object count) {
    return 'Add ($count)';
  }

  @override
  String get manage => 'Manage';

  @override
  String get viewAll => 'View all';

  @override
  String devicesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Devices',
      one: '1 Device',
    );
    return '$_temp0';
  }

  @override
  String devicesCountText(Object count) {
    return '$count Devices';
  }

  @override
  String lightsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Lights',
      one: '1 Light',
    );
    return '$_temp0';
  }

  @override
  String camerasCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Cameras',
      one: '1 Camera',
    );
    return '$_temp0';
  }

  @override
  String starsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String removeNamed(Object name) {
    return 'Remove $name';
  }

  @override
  String removedNamed(Object name) {
    return '$name removed';
  }

  @override
  String pageOf(Object current, Object total) {
    return 'Page $current of $total';
  }

  @override
  String get connected => 'Connected';

  @override
  String connectedInRoom(Object room) {
    return 'Connected · $room';
  }

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get poweredOn => 'Powered On';

  @override
  String get poweredOff => 'Powered Off';

  @override
  String get powerOn => 'Power On';

  @override
  String get powerOff => 'Power Off';

  @override
  String get on => 'ON';

  @override
  String get off => 'OFF';

  @override
  String get power => 'Power';

  @override
  String get turnOn => 'Turn on';

  @override
  String get turnOff => 'Turn off';

  @override
  String voltsToday(Object volts) {
    return '${volts}V - Today';
  }

  @override
  String batteryLevel(Object level) {
    return 'Battery $level%';
  }

  @override
  String batteryCharging(Object level) {
    return 'Battery $level%, charging';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navRooms => 'Rooms';

  @override
  String get navAddDevice => 'Add device';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navSettings => 'Settings';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get changeHome => 'Change home';

  @override
  String get defaultHomeName => 'My Home';

  @override
  String get searchDevices => 'Search Devices';

  @override
  String get voiceSearch => 'Voice search';

  @override
  String get voiceSearchSoon => 'Voice search is coming soon';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noDevicesFound => 'No devices found';

  @override
  String get addNewDevice => 'Add New Device';

  @override
  String get addRoom => 'Add Room';

  @override
  String get roomName => 'Room Name';

  @override
  String get addHome => 'Add Home';

  @override
  String get homeName => 'Home Name';

  @override
  String get manageHomes => 'Manage Homes';

  @override
  String get manageRoom => 'Manage Room';

  @override
  String get groupLights => 'Lights & Decoration';

  @override
  String get groupLightsList => 'Light';

  @override
  String get groupSecurity => 'Security';

  @override
  String get groupEntertainment => 'Entertainment';

  @override
  String get groupClimate => 'Climate';

  @override
  String get groupAppliances => 'Appliances';

  @override
  String get groupCleaning => 'Cleaning';

  @override
  String get couldntRefresh => 'Couldn\'t refresh. Check your connection.';

  @override
  String get loadingMore => 'Loading more';

  @override
  String get couldntLoadMore => 'Couldn\'t load more';

  @override
  String couldntTurnOn(Object name) {
    return 'Couldn\'t turn on $name. Check your connection.';
  }

  @override
  String couldntTurnOff(Object name) {
    return 'Couldn\'t turn off $name. Check your connection.';
  }

  @override
  String get couldntUpdateDevices =>
      'Couldn\'t update devices. Check your connection.';

  @override
  String get couldntAddRoom => 'Couldn\'t add the room. Check your connection.';

  @override
  String get couldntRemoveRoom =>
      'Couldn\'t remove the room. Check your connection.';

  @override
  String get couldntSaveHomes =>
      'Couldn\'t save your homes. Check your connection.';

  @override
  String get couldntAddDevices =>
      'Couldn\'t add the devices. Check your connection.';

  @override
  String roomExists(Object name) {
    return 'You already have a room named “$name”';
  }

  @override
  String get onboarding1Before => 'Control Your ';

  @override
  String get onboarding1Highlight => 'Uncontrolled';

  @override
  String get onboarding1After => '\nDevices with Hoome';

  @override
  String get onboarding1Desc =>
      'All New AI Home smart devices control at your fingertips';

  @override
  String get onboarding2Before => 'Seamless ';

  @override
  String get onboarding2Highlight => 'Integration';

  @override
  String get onboarding2After => ' for\nEvery Smart Device';

  @override
  String get onboarding2Desc =>
      'Connect and manage all your home gadgets in one powerful app — instantly and effortlessly';

  @override
  String get onboarding3Before => 'Smart, Secure, and ';

  @override
  String get onboarding3Highlight => 'Always';

  @override
  String get onboarding3After => '\nin Sync';

  @override
  String get onboarding3Desc =>
      'Experience peace of mind with real-time control, monitoring, and automation — wherever you are.';

  @override
  String get skipIntro => 'Skip Intro';

  @override
  String get letsGo => 'Let’s Go ✨';

  @override
  String get authWelcome => 'Welcome to Hoome’s world of digital technology.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get yourName => 'Your name';

  @override
  String get yourEmail => 'Your email address';

  @override
  String get createPassword => 'Create password';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String resetLinkSent(Object email) {
    return 'Password reset link sent to $email';
  }

  @override
  String get enterEmailToReset =>
      'Enter your email above to reset your password';

  @override
  String get agreePrefix => 'By creating an account you agree to Hoome’s ';

  @override
  String get agreeAnd => ' & ';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithEmail => 'Continue with email';

  @override
  String get continueWithPhone => 'Continue with phone number';

  @override
  String get signInAppleSoon => 'Sign in with Apple is coming soon';

  @override
  String get signInGoogleSoon => 'Sign in with Google is coming soon';

  @override
  String get signUpAppleSoon => 'Sign up with Apple is coming soon';

  @override
  String get signUpGoogleSoon => 'Sign up with Google is coming soon';

  @override
  String get googleSignInFailed => 'Google sign-in failed';

  @override
  String get haveAccount => 'Already have an account? ';

  @override
  String get login => 'Login';

  @override
  String get noAccount => 'Don’t have an account? ';

  @override
  String get verifyTitle => 'Verify That’s You';

  @override
  String get verifySubtitle =>
      'We just sent a 6-digit verification code to your email ';

  @override
  String get enterCode => 'Enter Code';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get newCodeSent => 'A new code has been sent to your email';

  @override
  String get changeEmail => 'Change email?';

  @override
  String get selectCountryCode => 'Select Country Code';

  @override
  String countryCodeChange(Object code) {
    return 'Country code $code, change';
  }

  @override
  String get phoneHint => 'Eg, 1234567890';

  @override
  String get rooms => 'Rooms';

  @override
  String removeRoomTitle(Object name) {
    return 'Remove $name?';
  }

  @override
  String get removeRoomMessage => 'This room will be removed from your home.';

  @override
  String get removeRoom => 'Remove Room';

  @override
  String get noDevicesInRoom => 'No devices in this room yet';

  @override
  String get temperatureUp => 'Temperature up';

  @override
  String get temperatureDown => 'Temperature down';

  @override
  String temperatureDegrees(Object temp) {
    return 'Temperature $temp degrees';
  }

  @override
  String get onCharge => 'On Charge';

  @override
  String get cleaning => 'Cleaning';

  @override
  String get idle => 'Idle';

  @override
  String get activityAlerts => 'Activity Alerts';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get notificationDismissed => 'Notification dismissed';

  @override
  String get reconnected => 'Re-connected successfully';

  @override
  String get reconnect => 'Re-Connect';

  @override
  String get turnOffAfter => 'Turn Off After';

  @override
  String turnOffAfterChange(Object minutes) {
    return 'Turn off after $minutes minutes, change';
  }

  @override
  String minutesShort(Object minutes) {
    return '$minutes Min';
  }

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(Object count) {
    return '$count Min ago';
  }

  @override
  String hoursAgo(Object count) {
    return '$count Hr ago';
  }

  @override
  String daysAgo(Object count) {
    return '$count Day ago';
  }

  @override
  String get settings => 'Settings';

  @override
  String get appTour => 'App Tour';

  @override
  String get shareApp => 'Share this app';

  @override
  String get appLinkCopied => 'App link copied to clipboard';

  @override
  String get rateUs => 'Rate Us';

  @override
  String thanksRating(Object stars) {
    return 'Thanks for rating us $stars★';
  }

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get yourFeedback => 'Your feedback';

  @override
  String get thanksFeedback => 'Thanks for your feedback!';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get logoutRow => 'Logout';

  @override
  String get logoutTitle => 'Log out?';

  @override
  String get logoutMessage =>
      'You will need to log in again to control your home.';

  @override
  String get logout => 'Log out';

  @override
  String get prefWireless => 'Wireless Connectivity';

  @override
  String get prefNotifications => 'Get Notifications';

  @override
  String get prefSaveData => 'Save device data';

  @override
  String get profile => 'Profile';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String tourStep(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get gotIt => 'Got it';

  @override
  String get tourHomeTitle => 'Your home';

  @override
  String get tourHomeMessage =>
      'Tap the home name to switch homes or add a new one. Everything in the app follows the home you pick.';

  @override
  String get tourFeaturedTitle => 'Quick controls';

  @override
  String get tourFeaturedMessage =>
      'Turn devices on or off right here. Swipe sideways for more, tap a card for details.';

  @override
  String get tourAddTitle => 'Add a device';

  @override
  String get tourAddMessage =>
      'Tap + to scan for nearby devices and add them to your home.';

  @override
  String get tourAlertsTitle => 'Notifications';

  @override
  String get tourAlertsMessage =>
      'Lights left on, devices offline… Alerts and suggestions show up here.';

  @override
  String get brightness => 'Brightness';

  @override
  String get cameraAngle => 'Camera angle';

  @override
  String get temperature => 'Temperature';

  @override
  String get warm => 'Warm';

  @override
  String get cool => 'Cool';

  @override
  String percentCool(Object percent) {
    return '$percent% cool';
  }

  @override
  String get colorTemperature => 'Color temperature';

  @override
  String hoursShort(Object hours) {
    return '$hours Hr';
  }

  @override
  String get runTime => 'Run time';

  @override
  String aqiValue(Object aqi) {
    return '$aqi AQI';
  }

  @override
  String get aqiGood => 'Good';

  @override
  String get aqiModerate => 'Moderate';

  @override
  String get aqiUnhealthy => 'Unhealthy';

  @override
  String get cameraOff => 'Camera off';

  @override
  String get quality => 'Quality';

  @override
  String get qualityDefault => 'Quality - Default';

  @override
  String get remote => 'Remote';

  @override
  String get mode => 'Mode';

  @override
  String get fanSpeed => 'Fan Speed';

  @override
  String get swing => 'Swing';

  @override
  String get swingLeft => 'Swing left';

  @override
  String get swingRight => 'Swing right';

  @override
  String get autoSwing => 'Auto swing';

  @override
  String get energyCtrl => 'Energy Ctrl';

  @override
  String get highCooling => 'High Cooling';

  @override
  String get acModeCool => 'Cool';

  @override
  String get acModeHeat => 'Heat';

  @override
  String get acModeDry => 'Dry';

  @override
  String get acModeFan => 'Fan';

  @override
  String get acModeAuto => 'Auto';

  @override
  String get fanAuto => 'Auto';

  @override
  String get fanLow => 'Low';

  @override
  String get fanMedium => 'Medium';

  @override
  String get fanHigh => 'High';

  @override
  String get breakShort => 'Break';

  @override
  String get breakBetweenRounds => 'Break between rounds';

  @override
  String secondsLong(Object count) {
    return '$count seconds';
  }

  @override
  String secondsShort(Object count) {
    return '$count Sec';
  }

  @override
  String get cleaningTime => 'Cleaning time';

  @override
  String minutesLong(Object count) {
    return '$count minutes';
  }

  @override
  String get minutesTitle => 'Minutes';

  @override
  String get scheduleTo => 'Schedule To';

  @override
  String get morning => 'Morning';

  @override
  String get noon => 'Noon';

  @override
  String get evening => 'Evening';

  @override
  String get night => 'Night';

  @override
  String get addDevices => 'Add Devices';

  @override
  String get chooseDeviceType =>
      'Choose a device type below. Keep your device close by to pair it quickly.';

  @override
  String noDevicesMatch(Object query) {
    return 'No devices match “$query”';
  }

  @override
  String get addTitle => 'Add ';

  @override
  String get pickModels =>
      'Pick one or more models below. Keep your device close by to pair it quickly.';

  @override
  String get missedDevice => 'Missed a device? ';

  @override
  String get scanNearby => 'Scan nearby devices';

  @override
  String get addNow => 'Add Now';

  @override
  String searchNamed(Object name) {
    return 'Search $name';
  }

  @override
  String noModelsYet(Object name) {
    return 'No $name models available yet.';
  }

  @override
  String noModelsMatch(Object query) {
    return 'No models match “$query”';
  }

  @override
  String get addedToHome => 'Added to your home';

  @override
  String get addingToHome => 'Adding to your home';

  @override
  String addingToHomeCount(Object current, Object total) {
    return 'Adding to your home ($current/$total)';
  }

  @override
  String signalConnected(Object name) {
    return '$name connected';
  }

  @override
  String signalConnecting(Object name) {
    return '$name connecting';
  }

  @override
  String signalWaiting(Object name) {
    return '$name waiting';
  }

  @override
  String get manageRoomsTitle => 'Manage Rooms & Devices';

  @override
  String get manageRoomsSubtitle =>
      'Pick a room, then tick the devices that belong to it';

  @override
  String get selectRoom => 'Select Room';

  @override
  String get assignDevices => 'Assign devices';

  @override
  String get noConnectedDevices => 'No connected devices yet.';

  @override
  String homeNumbered(Object number) {
    return 'Home $number';
  }

  @override
  String get createHome => 'Create Home';

  @override
  String get manageHomesSubtitle =>
      'Here you can add, update or delete your homes';

  @override
  String get removeHome => 'Remove home';

  @override
  String get stopScanning => 'Stop Scanning';

  @override
  String get allowAndContinue => 'Allow and Continue';

  @override
  String get addManually => 'Add Manually';

  @override
  String get scanRequirement =>
      'Make sure you have one or more smart devices that support Wi-Fi or Bluetooth';

  @override
  String get searching => 'Searching...';

  @override
  String get foundPrefix => 'Found ';

  @override
  String foundSuffix(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' Devices',
      one: ' Device',
    );
    return '$_temp0';
  }

  @override
  String get scanConnectHint =>
      'Please make sure all your devices are connected to Wi-Fi or Bluetooth';

  @override
  String get cantSeeDevice => 'Can’t see your device? Please scan again';

  @override
  String get allowCheck =>
      'Allow us to check nearby devices with Bluetooth or Wi-Fi';

  @override
  String get connecting => 'Connecting...';

  @override
  String get unableToConnect => 'Unable to connect';
}
