// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get languageName => 'Tiếng Việt';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get continueLabel => 'Tiếp tục';

  @override
  String get cancel => 'Huỷ';

  @override
  String get undo => 'Hoàn tác';

  @override
  String get retry => 'Thử lại';

  @override
  String get close => 'Đóng';

  @override
  String get back => 'Quay lại';

  @override
  String get next => 'Tiếp';

  @override
  String get skip => 'Bỏ qua';

  @override
  String get done => 'Xong';

  @override
  String get remove => 'Xoá';

  @override
  String get or => 'Hoặc';

  @override
  String get more => 'Thêm';

  @override
  String get update => 'Cập nhật';

  @override
  String get send => 'Gửi';

  @override
  String get submit => 'Gửi';

  @override
  String get add => 'Thêm';

  @override
  String addCount(Object count) {
    return 'Thêm ($count)';
  }

  @override
  String get manage => 'Quản lý';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String devicesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thiết bị',
    );
    return '$_temp0';
  }

  @override
  String devicesCountText(Object count) {
    return '$count thiết bị';
  }

  @override
  String lightsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count đèn',
    );
    return '$_temp0';
  }

  @override
  String camerasCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count camera',
    );
    return '$_temp0';
  }

  @override
  String starsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sao',
    );
    return '$_temp0';
  }

  @override
  String removeNamed(Object name) {
    return 'Xoá $name';
  }

  @override
  String removedNamed(Object name) {
    return 'Đã xoá $name';
  }

  @override
  String pageOf(Object current, Object total) {
    return 'Trang $current/$total';
  }

  @override
  String get connected => 'Đã kết nối';

  @override
  String connectedInRoom(Object room) {
    return 'Đã kết nối · $room';
  }

  @override
  String get online => 'Trực tuyến';

  @override
  String get offline => 'Ngoại tuyến';

  @override
  String get poweredOn => 'Đang bật';

  @override
  String get poweredOff => 'Đang tắt';

  @override
  String get powerOn => 'Đang bật';

  @override
  String get powerOff => 'Đang tắt';

  @override
  String get on => 'BẬT';

  @override
  String get off => 'TẮT';

  @override
  String get power => 'Nguồn';

  @override
  String get turnOn => 'Bật';

  @override
  String get turnOff => 'Tắt';

  @override
  String voltsToday(Object volts) {
    return '${volts}V - Hôm nay';
  }

  @override
  String batteryLevel(Object level) {
    return 'Pin $level%';
  }

  @override
  String batteryCharging(Object level) {
    return 'Pin $level%, đang sạc';
  }

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navRooms => 'Phòng';

  @override
  String get navAddDevice => 'Thêm thiết bị';

  @override
  String get navNotifications => 'Thông báo';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get welcomeBack => 'Chào mừng trở lại';

  @override
  String get changeHome => 'Đổi nhà';

  @override
  String get defaultHomeName => 'Nhà của tôi';

  @override
  String get searchDevices => 'Tìm thiết bị';

  @override
  String get voiceSearch => 'Tìm bằng giọng nói';

  @override
  String get voiceSearchSoon => 'Tìm bằng giọng nói sắp ra mắt';

  @override
  String get clearSearch => 'Xoá tìm kiếm';

  @override
  String get noDevicesFound => 'Không tìm thấy thiết bị';

  @override
  String get addNewDevice => 'Thêm thiết bị mới';

  @override
  String get addRoom => 'Thêm phòng';

  @override
  String get roomName => 'Tên phòng';

  @override
  String get addHome => 'Thêm nhà';

  @override
  String get homeName => 'Tên nhà';

  @override
  String get manageHomes => 'Quản lý nhà';

  @override
  String get manageRoom => 'Quản lý phòng';

  @override
  String get groupLights => 'Đèn & trang trí';

  @override
  String get groupLightsList => 'Đèn';

  @override
  String get groupSecurity => 'An ninh';

  @override
  String get groupEntertainment => 'Giải trí';

  @override
  String get groupClimate => 'Nhiệt độ';

  @override
  String get groupAppliances => 'Thiết bị gia dụng';

  @override
  String get groupCleaning => 'Dọn dẹp';

  @override
  String get couldntRefresh => 'Không làm mới được. Hãy kiểm tra kết nối mạng.';

  @override
  String get loadingMore => 'Đang tải thêm';

  @override
  String get couldntLoadMore => 'Không tải thêm được';

  @override
  String couldntTurnOn(Object name) {
    return 'Không bật được $name. Hãy kiểm tra kết nối mạng.';
  }

  @override
  String couldntTurnOff(Object name) {
    return 'Không tắt được $name. Hãy kiểm tra kết nối mạng.';
  }

  @override
  String get couldntUpdateDevices =>
      'Không cập nhật được thiết bị. Hãy kiểm tra kết nối mạng.';

  @override
  String get couldntAddRoom =>
      'Không thêm được phòng. Hãy kiểm tra kết nối mạng.';

  @override
  String get couldntRemoveRoom =>
      'Không xoá được phòng. Hãy kiểm tra kết nối mạng.';

  @override
  String get couldntSaveHomes =>
      'Không lưu được danh sách nhà. Hãy kiểm tra kết nối mạng.';

  @override
  String get couldntAddDevices =>
      'Không thêm được thiết bị. Hãy kiểm tra kết nối mạng.';

  @override
  String roomExists(Object name) {
    return 'Bạn đã có phòng tên “$name”';
  }

  @override
  String get onboarding1Before => 'Điều khiển ';

  @override
  String get onboarding1Highlight => 'mọi thiết bị';

  @override
  String get onboarding1After => '\ntrong nhà với Hoome';

  @override
  String get onboarding1Desc =>
      'Mọi thiết bị thông minh trong nhà, điều khiển ngay trong tầm tay';

  @override
  String get onboarding2Before => 'Kết nối ';

  @override
  String get onboarding2Highlight => 'liền mạch';

  @override
  String get onboarding2After => '\nmọi thiết bị thông minh';

  @override
  String get onboarding2Desc =>
      'Kết nối và quản lý mọi thiết bị trong nhà bằng một ứng dụng — nhanh chóng và dễ dàng';

  @override
  String get onboarding3Before => 'Thông minh, an toàn, ';

  @override
  String get onboarding3Highlight => 'luôn';

  @override
  String get onboarding3After => '\nđồng bộ';

  @override
  String get onboarding3Desc =>
      'Yên tâm điều khiển, theo dõi và tự động hoá theo thời gian thực — dù bạn ở bất cứ đâu.';

  @override
  String get skipIntro => 'Bỏ qua';

  @override
  String get letsGo => 'Bắt đầu ✨';

  @override
  String get authWelcome =>
      'Chào mừng bạn đến với thế giới công nghệ số của Hoome.';

  @override
  String get createAccount => 'Tạo tài khoản';

  @override
  String get yourName => 'Tên của bạn';

  @override
  String get yourEmail => 'Địa chỉ email của bạn';

  @override
  String get createPassword => 'Tạo mật khẩu';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get showPassword => 'Hiện mật khẩu';

  @override
  String get hidePassword => 'Ẩn mật khẩu';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String resetLinkSent(Object email) {
    return 'Đã gửi liên kết đặt lại mật khẩu tới $email';
  }

  @override
  String get enterEmailToReset => 'Nhập email ở trên để đặt lại mật khẩu';

  @override
  String get agreePrefix => 'Khi tạo tài khoản, bạn đồng ý với ';

  @override
  String get agreeAnd => ' và ';

  @override
  String get continueWithApple => 'Tiếp tục với Apple';

  @override
  String get continueWithGoogle => 'Tiếp tục với Google';

  @override
  String get continueWithEmail => 'Tiếp tục với email';

  @override
  String get continueWithPhone => 'Tiếp tục với số điện thoại';

  @override
  String get signInAppleSoon => 'Đăng nhập bằng Apple sắp ra mắt';

  @override
  String get signInGoogleSoon => 'Đăng nhập bằng Google sắp ra mắt';

  @override
  String get signUpAppleSoon => 'Đăng ký bằng Apple sắp ra mắt';

  @override
  String get signUpGoogleSoon => 'Đăng ký bằng Google sắp ra mắt';

  @override
  String get googleSignInFailed => 'Đăng nhập Google thất bại';

  @override
  String get haveAccount => 'Đã có tài khoản? ';

  @override
  String get login => 'Đăng nhập';

  @override
  String get noAccount => 'Chưa có tài khoản? ';

  @override
  String get verifyTitle => 'Xác minh tài khoản';

  @override
  String get verifySubtitle =>
      'Chúng tôi vừa gửi mã xác minh 6 chữ số tới email ';

  @override
  String get enterCode => 'Nhập mã';

  @override
  String get resendCode => 'Gửi lại mã';

  @override
  String get newCodeSent => 'Đã gửi mã mới tới email của bạn';

  @override
  String get changeEmail => 'Đổi email?';

  @override
  String get selectCountryCode => 'Chọn mã quốc gia';

  @override
  String countryCodeChange(Object code) {
    return 'Mã quốc gia $code, đổi';
  }

  @override
  String get phoneHint => 'VD: 1234567890';

  @override
  String get rooms => 'Phòng';

  @override
  String removeRoomTitle(Object name) {
    return 'Xoá $name?';
  }

  @override
  String get removeRoomMessage => 'Phòng này sẽ bị xoá khỏi nhà của bạn.';

  @override
  String get removeRoom => 'Xoá phòng';

  @override
  String get noDevicesInRoom => 'Phòng này chưa có thiết bị';

  @override
  String get temperatureUp => 'Tăng nhiệt độ';

  @override
  String get temperatureDown => 'Giảm nhiệt độ';

  @override
  String temperatureDegrees(Object temp) {
    return 'Nhiệt độ $temp độ';
  }

  @override
  String get onCharge => 'Đang sạc';

  @override
  String get cleaning => 'Đang dọn';

  @override
  String get idle => 'Đang nghỉ';

  @override
  String get activityAlerts => 'Thông báo';

  @override
  String get noNotifications => 'Chưa có thông báo';

  @override
  String get notificationDismissed => 'Đã ẩn thông báo';

  @override
  String get reconnected => 'Kết nối lại thành công';

  @override
  String get reconnect => 'Kết nối lại';

  @override
  String get turnOffAfter => 'Tắt sau';

  @override
  String turnOffAfterChange(Object minutes) {
    return 'Tắt sau $minutes phút, đổi';
  }

  @override
  String minutesShort(Object minutes) {
    return '$minutes phút';
  }

  @override
  String get justNow => 'Vừa xong';

  @override
  String minutesAgo(Object count) {
    return '$count phút trước';
  }

  @override
  String hoursAgo(Object count) {
    return '$count giờ trước';
  }

  @override
  String daysAgo(Object count) {
    return '$count ngày trước';
  }

  @override
  String get settings => 'Cài đặt';

  @override
  String get appTour => 'Hướng dẫn sử dụng';

  @override
  String get shareApp => 'Chia sẻ ứng dụng';

  @override
  String get appLinkCopied => 'Đã sao chép liên kết ứng dụng';

  @override
  String get rateUs => 'Đánh giá ứng dụng';

  @override
  String thanksRating(Object stars) {
    return 'Cảm ơn bạn đã đánh giá $stars★';
  }

  @override
  String get sendFeedback => 'Gửi góp ý';

  @override
  String get yourFeedback => 'Góp ý của bạn';

  @override
  String get thanksFeedback => 'Cảm ơn góp ý của bạn!';

  @override
  String get privacyPolicy => 'Chính sách quyền riêng tư';

  @override
  String get termsOfUse => 'Điều khoản sử dụng';

  @override
  String get logoutRow => 'Đăng xuất';

  @override
  String get logoutTitle => 'Đăng xuất?';

  @override
  String get logoutMessage =>
      'Bạn sẽ cần đăng nhập lại để điều khiển nhà của mình.';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get prefWireless => 'Kết nối không dây';

  @override
  String get prefNotifications => 'Nhận thông báo';

  @override
  String get prefSaveData => 'Lưu dữ liệu thiết bị';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get profileUpdated => 'Đã cập nhật hồ sơ';

  @override
  String tourStep(Object current, Object total) {
    return 'Bước $current/$total';
  }

  @override
  String get gotIt => 'Đã hiểu';

  @override
  String get tourHomeTitle => 'Nhà của bạn';

  @override
  String get tourHomeMessage =>
      'Chạm vào tên nhà để chuyển sang nhà khác hoặc thêm nhà mới. Mọi thứ trong app đổi theo nhà bạn chọn.';

  @override
  String get tourFeaturedTitle => 'Điều khiển nhanh';

  @override
  String get tourFeaturedMessage =>
      'Bật/tắt thiết bị ngay tại đây. Vuốt ngang để xem thêm, chạm vào thẻ để xem chi tiết.';

  @override
  String get tourAddTitle => 'Thêm thiết bị';

  @override
  String get tourAddMessage => 'Chạm + để quét thiết bị ở gần và thêm vào nhà.';

  @override
  String get tourAlertsTitle => 'Thông báo';

  @override
  String get tourAlertsMessage =>
      'Đèn quên tắt, thiết bị mất kết nối… Cảnh báo và gợi ý sẽ hiện ở đây.';

  @override
  String get brightness => 'Độ sáng';

  @override
  String get cameraAngle => 'Góc camera';

  @override
  String get temperature => 'Nhiệt độ';

  @override
  String get warm => 'Ấm';

  @override
  String get cool => 'Lạnh';

  @override
  String percentCool(Object percent) {
    return '$percent% lạnh';
  }

  @override
  String get colorTemperature => 'Nhiệt độ màu';

  @override
  String hoursShort(Object hours) {
    return '$hours giờ';
  }

  @override
  String get runTime => 'Thời gian chạy';

  @override
  String aqiValue(Object aqi) {
    return '$aqi AQI';
  }

  @override
  String get aqiGood => 'Tốt';

  @override
  String get aqiModerate => 'Trung bình';

  @override
  String get aqiUnhealthy => 'Không tốt';

  @override
  String get cameraOff => 'Camera đang tắt';

  @override
  String get quality => 'Chất lượng';

  @override
  String get qualityDefault => 'Chất lượng - Mặc định';

  @override
  String get remote => 'Điều khiển';

  @override
  String get mode => 'Chế độ';

  @override
  String get fanSpeed => 'Tốc độ quạt';

  @override
  String get swing => 'Đảo gió';

  @override
  String get swingLeft => 'Đảo gió sang trái';

  @override
  String get swingRight => 'Đảo gió sang phải';

  @override
  String get autoSwing => 'Đảo gió tự động';

  @override
  String get energyCtrl => 'Tiết kiệm';

  @override
  String get highCooling => 'Làm lạnh nhanh';

  @override
  String get acModeCool => 'Làm lạnh';

  @override
  String get acModeHeat => 'Sưởi';

  @override
  String get acModeDry => 'Hút ẩm';

  @override
  String get acModeFan => 'Quạt';

  @override
  String get acModeAuto => 'Tự động';

  @override
  String get fanAuto => 'Tự động';

  @override
  String get fanLow => 'Thấp';

  @override
  String get fanMedium => 'Vừa';

  @override
  String get fanHigh => 'Cao';

  @override
  String get breakShort => 'Nghỉ';

  @override
  String get breakBetweenRounds => 'Nghỉ giữa các vòng';

  @override
  String secondsLong(Object count) {
    return '$count giây';
  }

  @override
  String secondsShort(Object count) {
    return '$count giây';
  }

  @override
  String get cleaningTime => 'Thời gian dọn';

  @override
  String minutesLong(Object count) {
    return '$count phút';
  }

  @override
  String get minutesTitle => 'Phút';

  @override
  String get scheduleTo => 'Hẹn giờ';

  @override
  String get morning => 'Sáng';

  @override
  String get noon => 'Trưa';

  @override
  String get evening => 'Chiều';

  @override
  String get night => 'Tối';

  @override
  String get addDevices => 'Thêm thiết bị';

  @override
  String get chooseDeviceType =>
      'Chọn loại thiết bị bên dưới. Để thiết bị ở gần để ghép nối nhanh hơn.';

  @override
  String noDevicesMatch(Object query) {
    return 'Không có thiết bị nào khớp “$query”';
  }

  @override
  String get addTitle => 'Thêm ';

  @override
  String get pickModels =>
      'Chọn một hoặc nhiều mẫu bên dưới. Để thiết bị ở gần để ghép nối nhanh hơn.';

  @override
  String get missedDevice => 'Còn thiếu thiết bị? ';

  @override
  String get scanNearby => 'Quét thiết bị ở gần';

  @override
  String get addNow => 'Thêm ngay';

  @override
  String searchNamed(Object name) {
    return 'Tìm $name';
  }

  @override
  String noModelsYet(Object name) {
    return 'Chưa có mẫu $name nào.';
  }

  @override
  String noModelsMatch(Object query) {
    return 'Không có mẫu nào khớp “$query”';
  }

  @override
  String get addedToHome => 'Đã thêm vào nhà';

  @override
  String get addingToHome => 'Đang thêm vào nhà';

  @override
  String addingToHomeCount(Object current, Object total) {
    return 'Đang thêm vào nhà ($current/$total)';
  }

  @override
  String signalConnected(Object name) {
    return '$name đã kết nối';
  }

  @override
  String signalConnecting(Object name) {
    return '$name đang kết nối';
  }

  @override
  String signalWaiting(Object name) {
    return '$name đang chờ';
  }

  @override
  String get manageRoomsTitle => 'Quản lý phòng & thiết bị';

  @override
  String get manageRoomsSubtitle =>
      'Chọn một phòng, rồi đánh dấu các thiết bị thuộc phòng đó';

  @override
  String get selectRoom => 'Chọn phòng';

  @override
  String get assignDevices => 'Gán thiết bị';

  @override
  String get noConnectedDevices => 'Chưa có thiết bị nào được kết nối.';

  @override
  String homeNumbered(Object number) {
    return 'Nhà $number';
  }

  @override
  String get createHome => 'Tạo nhà';

  @override
  String get manageHomesSubtitle => 'Tại đây bạn có thể thêm, sửa hoặc xoá nhà';

  @override
  String get removeHome => 'Xoá nhà';

  @override
  String get stopScanning => 'Dừng quét';

  @override
  String get allowAndContinue => 'Cho phép và tiếp tục';

  @override
  String get addManually => 'Thêm thủ công';

  @override
  String get scanRequirement =>
      'Hãy chắc chắn bạn có ít nhất một thiết bị thông minh hỗ trợ Wi-Fi hoặc Bluetooth';

  @override
  String get searching => 'Đang tìm...';

  @override
  String get foundPrefix => 'Tìm thấy ';

  @override
  String foundSuffix(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' thiết bị',
    );
    return '$_temp0';
  }

  @override
  String get scanConnectHint =>
      'Hãy chắc chắn mọi thiết bị đã kết nối Wi-Fi hoặc Bluetooth';

  @override
  String get cantSeeDevice => 'Không thấy thiết bị? Hãy quét lại';

  @override
  String get allowCheck =>
      'Cho phép tìm thiết bị ở gần qua Bluetooth hoặc Wi-Fi';

  @override
  String get connecting => 'Đang kết nối...';

  @override
  String get unableToConnect => 'Không kết nối được';
}
