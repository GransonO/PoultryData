class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'PoultryData';
  static const String appTagline = 'Agricultural Poultry Capture';

  // Auth
  static const String loginTitle = 'Welcome to PoultryData';
  static const String loginSubtitle = 'Register your details to continue';
  static const String nameLabelText = 'Full Name';
  static const String nameHint = 'e.g. John Doe';
  static const String phoneLabel = 'Phone Number';
  static const String phoneHint = 'e.g. +254 712 345 678';
  static const String emailLabel = 'Email Address';
  static const String emailHint = 'e.g. john@example.com';
  static const String registerButton = 'Register & Continue';
  static const String alreadyHaveAccount = 'Already registered? ';
  static const String continueText = 'Continue';

  // Validation
  static const String nameRequired = 'Please enter your full name';
  static const String nameTooShort = 'Name must be at least 2 characters';
  static const String phoneRequired = 'Please enter your phone number';
  static const String phoneInvalid = 'Please enter a valid phone number';
  static const String emailRequired = 'Please enter your email address';
  static const String emailInvalid = 'Please enter a valid email address';

  // Home
  static const String homeTitle = 'PoultryData';
  static const String captureChicken = 'Capture Chicken';
  static const String viewGallery = 'View Gallery';
  static const String totalCaptures = 'Total Captures';
  static const String photos = 'Photos';
  static const String videos = 'Videos';
  static const String homeWelcome = 'Hello';
  static const String homeSubtitle = 'Ready to capture poultry data?';
  static const String quickActions = 'Quick Actions';
  static const String recentCaptures = 'Recent Captures';
  static const String noRecentCaptures = 'No captures yet.\nTap Capture Chicken to get started.';

  // Camera
  static const String cameraTitle = 'Capture Chicken';
  static const String photoMode = 'Photo';
  static const String videoMode = 'Video';
  static const String fullBodyMode = 'Full Body';
  static const String closeUpMode = 'Close-up';
  static const String startRecording = 'Start Recording';
  static const String stopRecording = 'Stop Recording';
  static const String capture = 'Capture';
  static const String captureSaved = 'Capture saved to gallery';
  static const String cameraError = 'Camera not available';
  static const String cameraInitializing = 'Initializing camera...';
  static const String permissionRequired = 'Camera permission required';
  static const String grantPermission = 'Grant Permission';

  // Capture Tips - Full Body
  static const List<String> fullBodyTips = [
    'Ensure the entire chicken is within the frame',
    'Both feet and the tail should be visible',
    'Keep at least 0.5m distance for full body',
    'Avoid cutting off wings or tail feathers',
    'Position the chicken against a plain background',
    'Ensure even lighting across the whole body',
  ];

  // Capture Tips - Close-up
  static const List<String> closeUpTips = [
    'Focus on the head and facial features',
    'Ensure the comb, beak, and eyes are clearly visible',
    'Move closer for sharp facial detail',
    'Avoid harsh shadows on the face',
    'Keep the chicken's head steady and centered',
    'Wattles and earlobes should be clearly visible',
  ];

  // General Tips
  static const List<String> generalTips = [
    'Hold your device steady to avoid blur',
    'Ensure good natural or artificial lighting',
    'Avoid busy or cluttered backgrounds',
    'Keep the chicken calm before capturing',
    'Clean your camera lens for sharper images',
  ];

  // Gallery
  static const String galleryTitle = 'Gallery';
  static const String allCaptures = 'All';
  static const String noCaptures = 'No captures yet';
  static const String noCapturesSubtitle = 'Go to the camera to capture chicken photos and videos';
  static const String deleteCapture = 'Delete';
  static const String shareCapture = 'Share';
  static const String captureDetails = 'Capture Details';
  static const String capturedOn = 'Captured on';
  static const String captureType = 'Type';
  static const String captureMode = 'Mode';
  static const String capturedBy = 'Captured by';
  static const String deleteConfirmTitle = 'Delete Capture?';
  static const String deleteConfirmBody = 'This action cannot be undone.';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
}
