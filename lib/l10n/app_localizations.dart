import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('fr')
  ];

  /// A welcome message
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Welcome back message
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Placeholder for email input
  ///
  /// In en, this message translates to:
  /// **'Enter Email'**
  String get enterEmail;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Placeholder for password input
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPassword;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign-up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Prompt for new users
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAccount;

  /// Button text for account creation
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// Sign-up instructions
  ///
  /// In en, this message translates to:
  /// **'Let’s help you set up your account, \nit won’t take long.'**
  String get registerDetails;

  /// Placeholder for name input
  ///
  /// In en, this message translates to:
  /// **'Enter Name'**
  String get enterName;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Placeholder for confirm password input
  ///
  /// In en, this message translates to:
  /// **'Retype Password'**
  String get enterConfirmPassword;

  /// Checkbox label for accepting terms
  ///
  /// In en, this message translates to:
  /// **'Accept terms & Condition'**
  String get acceptTermsAndConditions;

  /// Prompt for returning users
  ///
  /// In en, this message translates to:
  /// **'Already a member?'**
  String get alreadyAMember;

  /// Validation message for required fields
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldCannotBeEmpty;

  /// Validation message for invalid email
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// Error message for user not found
  ///
  /// In en, this message translates to:
  /// **'There is no user record linked to this email'**
  String get userNotFound;

  /// Error message for sign-up failure
  ///
  /// In en, this message translates to:
  /// **'Register failed'**
  String get registerFailed;

  /// Success message for registration
  ///
  /// In en, this message translates to:
  /// **'You have successfully registered'**
  String get registerSuccess;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Previous button text
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Finish button text
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Notification prompt
  ///
  /// In en, this message translates to:
  /// **'Do you want to receive notifications?'**
  String get wantToReceiveNotification;

  /// Yes option
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No option
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Encouraging message for meal preparation
  ///
  /// In en, this message translates to:
  /// **'Let’s create delicious meals today'**
  String get letCreateMealToday;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again'**
  String get somethingWentWrong;

  /// Ingredients section title
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// Steps section title
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// Error message for retrieving recipes
  ///
  /// In en, this message translates to:
  /// **'Error retrieving recipes'**
  String get receipeRetrievalError;

  /// Quick recipes section title
  ///
  /// In en, this message translates to:
  /// **'Quick Recipes'**
  String get quickRecipes;

  /// Kitchen inventory section title
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get yourKitchenInventory;

  /// Message when kitchen inventory is empty
  ///
  /// In en, this message translates to:
  /// **'It looks like your kitchen inventory is empty!'**
  String get emptyKitchenText;

  /// Prompt to manually add inventory
  ///
  /// In en, this message translates to:
  /// **'Click here to add manually'**
  String get clickHereToAdd;

  /// Alternative choice separator
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Prompt to scan a receipt
  ///
  /// In en, this message translates to:
  /// **'Take your receipt picture'**
  String get takeYourReceiptPicture;

  /// Button text for adding kitchen inventory
  ///
  /// In en, this message translates to:
  /// **'Add Inventory Kitchen'**
  String get addKitchen;

  /// Label for quantity input
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Placeholder for quantity input
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get enterQuantity;

  /// Button text for validation
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// Success message for adding an ingredient
  ///
  /// In en, this message translates to:
  /// **'Ingredient added successfully'**
  String get addIngredientSuccess;

  /// Text for forgot password
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Text for forgotten password (full version)
  ///
  /// In en, this message translates to:
  /// **'Forgotten Password'**
  String get forgotternPassword;

  /// Message displayed when password reset email is sent
  ///
  /// In en, this message translates to:
  /// **'We have sent you an email to reset your password'**
  String get resetPasswordSuccess;

  /// Text for changing user preferences
  ///
  /// In en, this message translates to:
  /// **'Change your preferences'**
  String get updateUserPreference;

  /// Error message displayed when account deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete your account. An error occurred'**
  String get deleteAccountError;

  /// Message displayed when the account deletion is successful
  ///
  /// In en, this message translates to:
  /// **'We’re sorry to see you go. Your account has been successfully deleted.'**
  String get deleteAccountSuccess;

  /// Label for changing user preferences
  ///
  /// In en, this message translates to:
  /// **'Change Preferences'**
  String get changesPreferences;

  /// Label for deleting the user account
  ///
  /// In en, this message translates to:
  /// **'Delete your account'**
  String get deleteAccount;

  /// Message asking the user to confirm account deletion
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete your account?'**
  String get confirmAccountDeletion;

  /// Label for the action of deleting
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Message informing the user they need to log in again to delete their account
  ///
  /// In en, this message translates to:
  /// **'You need to login again to delete your account'**
  String get deleteAccountRequiredRecentLogin;

  /// Message displayed when the password entered is incorrect
  ///
  /// In en, this message translates to:
  /// **'The password is incorrect. Try again or reset your password on the settings page.'**
  String get deleteAccountIncorrectPassword;

  /// Message displayed when no recipes are available
  ///
  /// In en, this message translates to:
  /// **'No recipes 😉. \nGo update your preferences'**
  String get emptyReceipes;

  /// Label for recipe ideas section
  ///
  /// In en, this message translates to:
  /// **'Recipe ideas'**
  String get receipeIdeas;

  /// Description explaining the recipe suggestions based on user inventory
  ///
  /// In en, this message translates to:
  /// **'We are suggesting some recipes \nbased on your inventory.'**
  String get receipeIdeasDescription;

  /// Message displayed when recipe ideas cannot be generated due to insufficient ingredients or preferences
  ///
  /// In en, this message translates to:
  /// **'We cannot generate recipe ideas for you. Please add more ingredients to your inventory and select your preferences.'**
  String get cannotGenerateReceipeIdeas;

  /// Label for the action of searching for ingredients
  ///
  /// In en, this message translates to:
  /// **'Add or search for ingredients'**
  String get searchForIngredients;

  /// Label for the action of adding an item
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// Label for the section displaying the user's items
  ///
  /// In en, this message translates to:
  /// **'My Items'**
  String get myItems;

  /// Message displayed when an ingredient is successfully removed
  ///
  /// In en, this message translates to:
  /// **'Ingredient removed'**
  String get ingredientRemoved;

  /// Label for the action of selecting a picture
  ///
  /// In en, this message translates to:
  /// **'Select picture'**
  String get selectPicture;

  /// Label for the action of taking a photo
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// Label for the action of scanning a receipt or ticket
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt Ticket'**
  String get scanReceiptTicket;

  /// Message displayed when the receipt or ticket scan fails
  ///
  /// In en, this message translates to:
  /// **'Failed to scan receipt ticket'**
  String get receiptTicketScanError;

  /// Message displayed when there are no notifications for the user
  ///
  /// In en, this message translates to:
  /// **'No notifications for \nyou yet 😉!'**
  String get notificationEmptyTitle;

  /// Title for the first onboarding step about filling the kitchen inventory
  ///
  /// In en, this message translates to:
  /// **'Discover all the best recipes you needed'**
  String get onboardingTitle1;

  /// Description for the first onboarding step about uploading kitchen inventory or invoices
  ///
  /// In en, this message translates to:
  /// **'5000+ healthy recipes made by people for your healthy life'**
  String get onboardingDesc1;

  /// Title for the third onboarding step about personalized preferences
  ///
  /// In en, this message translates to:
  /// **'Let\'s cook with the recipe you found'**
  String get onboardingTitle3;

  /// Description for third onboarding step
  ///
  /// In en, this message translates to:
  /// **'Cooking based on the food recipes you find and the food you love'**
  String get onboardingDesc3;

  /// Title for the second onboarding step about smart recipe generation
  ///
  /// In en, this message translates to:
  /// **'Order directly the ingredients'**
  String get onboardingTitle2;

  /// Description for the second onboarding step about generating recipes from ingredients
  ///
  /// In en, this message translates to:
  /// **'Order the ingredients you need quickly with a fast process'**
  String get onboardingDesc2;

  /// Label for the button to skip a step
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Label for the French food category
  ///
  /// In en, this message translates to:
  /// **'French Food'**
  String get frenchFood;

  /// Description for the start screen about transforming ingredients into dishes
  ///
  /// In en, this message translates to:
  /// **'Turn your ingredients into culinary \nmasterpieces.'**
  String get startScreenDescription;

  /// Label for the action of starting to cook
  ///
  /// In en, this message translates to:
  /// **'Start Cooking'**
  String get startCooking;

  /// Message displayed when the user's preferences are successfully updated
  ///
  /// In en, this message translates to:
  /// **'Your preferences have been updated.'**
  String get updateUserPreferenceSuccess;

  /// Message displayed when there is no change in the user's preferences
  ///
  /// In en, this message translates to:
  /// **'No change in your preferences.'**
  String get noChangeInUserPreference;

  /// Label for the action of updating something
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Title for the app bar when displaying receipt ticket scan results
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt Ticket Result'**
  String get scanReceiptTicketAppbar;

  /// Description of the AI-powered receipt scanning process with a note about potential errors
  ///
  /// In en, this message translates to:
  /// **'(We’re using AI to extract informations from your ticket. Mistake can happen, please check and edit if necessary.)'**
  String get scanAiReceiptDescription;

  /// Label for the action of adding an item to the kitchen inventory
  ///
  /// In en, this message translates to:
  /// **'Add to inventory'**
  String get addToKitchenInvontory;

  /// Message displayed when there are no saved recipes
  ///
  /// In en, this message translates to:
  /// **'No saved recipes 😉. \nGo select between your available recipes!'**
  String get noSavedReceipes;

  /// Label for the favorite section
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorite;

  /// Label for the action of signing out
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get signOut;

  /// Placeholder for product name input
  ///
  /// In en, this message translates to:
  /// **'Enter Product Name'**
  String get enterProductName;

  /// Label for request canceled
  ///
  /// In en, this message translates to:
  /// **'Request Canceled'**
  String get requestCanceled;

  /// Label for sign in With
  ///
  /// In en, this message translates to:
  /// **'Or Sign in With'**
  String get signInWith;

  /// Label for password requirement
  ///
  /// In en, this message translates to:
  /// **'Your password should contain at least'**
  String get passwordRequirement;

  /// Label for password length
  ///
  /// In en, this message translates to:
  /// **'06 characters'**
  String get passwordLength;

  /// Label for at least one number
  ///
  /// In en, this message translates to:
  /// **'one number'**
  String get atLeastOneNumber;

  /// Label for at least one uppercase letter
  ///
  /// In en, this message translates to:
  /// **'one uppercase letter'**
  String get atLeastOneUpperCaseLetter;

  /// Label for continue with Apple
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Label for continue with Google
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Label for continue with email
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get continueWithEmail;

  /// Label for let's cook
  ///
  /// In en, this message translates to:
  /// **'Let\'s cook!'**
  String get letsCook;

  /// Label for step
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// Label for average time
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get averageTime;

  /// Label for generating recipes
  ///
  /// In en, this message translates to:
  /// **'Generate Recipe'**
  String get generateRecipe;

  /// Label for generating recipes from a photo of groceries
  ///
  /// In en, this message translates to:
  /// **'From groceries photo'**
  String get generateRecipeWithGroceriePhoto;

  /// Label for generating recipes from a list of groceries
  ///
  /// In en, this message translates to:
  /// **'From your groceries list'**
  String get generateRecipeWithGrocerieList;

  /// Label for filling your kitchen with goodness
  ///
  /// In en, this message translates to:
  /// **'Let’s fill your kitchen with goodness'**
  String get fillKitchen;

  /// Label for sending a bug
  ///
  /// In en, this message translates to:
  /// **'Send a bug'**
  String get sendABug;

  /// Label for changing the language
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// Label for history
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historic;

  /// Label for empty historic
  ///
  /// In en, this message translates to:
  /// **'Oops 🥲, your recipe history is empty'**
  String get emptyHistoric;

  /// Label for app update available
  ///
  /// In en, this message translates to:
  /// **'App update available 🥳 !'**
  String get updateAvailable;

  /// Label for update available description
  ///
  /// In en, this message translates to:
  /// **'A new version of our application is now available. Update now to take full advantage of all the new features.'**
  String get updateAvailableDescription;

  /// Label for base settings
  ///
  /// In en, this message translates to:
  /// **'Base Settings'**
  String get baseSettings;

  /// Label for my account
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// Label for my languages
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get language;

  /// Label for kitchen settings
  ///
  /// In en, this message translates to:
  /// **'Kitchen Settings'**
  String get kitchenSettings;

  /// Label for my preferences
  ///
  /// In en, this message translates to:
  /// **'My Preferences'**
  String get myPreferences;

  /// Label for notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notification;

  /// Label for help
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Label for user name
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get nameUser;

  /// Label for changing username
  ///
  /// In en, this message translates to:
  /// **'Change your username'**
  String get changeUsername;

  /// Label for username not changed
  ///
  /// In en, this message translates to:
  /// **'Username not changed'**
  String get usernameNotChanged;

  /// Label for username changed
  ///
  /// In en, this message translates to:
  /// **'Username changed'**
  String get usernameChanged;

  /// Label for changing email
  ///
  /// In en, this message translates to:
  /// **'Change your email'**
  String get changeEmail;

  /// Label for change email description
  ///
  /// In en, this message translates to:
  /// **'Enter the new email address. We will send you an email to change your email address'**
  String get changeEmailDescription;

  /// Label for getting the link
  ///
  /// In en, this message translates to:
  /// **'Get the link'**
  String get getTheLink;

  /// Label for email not changed
  ///
  /// In en, this message translates to:
  /// **'Email not changed'**
  String get emailNotChanged;

  /// Label for email changed
  ///
  /// In en, this message translates to:
  /// **'Check your inbox for the email change link'**
  String get emailChanged;

  /// Label for login in again to change email
  ///
  /// In en, this message translates to:
  /// **'You need to login again to change your email'**
  String get loginInAgainToChangeEmail;

  /// Label for change
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Label for changing password
  ///
  /// In en, this message translates to:
  /// **'Change your password'**
  String get changePassword;

  /// Label for change password description
  ///
  /// In en, this message translates to:
  /// **'We will send you an email to change your password'**
  String get changePasswordDescription;

  /// Label for change password email sent
  ///
  /// In en, this message translates to:
  /// **'Check your inbox for the email change link'**
  String get changePasswordEmailSent;

  /// Label for checking your email
  ///
  /// In en, this message translates to:
  /// **'Check your email for the link to change your password'**
  String get checkYourEmail;

  /// Label for selecting language
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get selectLanguage;

  /// Label for sharing the link
  ///
  /// In en, this message translates to:
  /// **'The recipe link has been copied to your clipboard'**
  String get shareLink;

  /// Label for internal server error
  ///
  /// In en, this message translates to:
  /// **'Oops 😵‍💫. An error occurred. Please try again.'**
  String get internalServerError;

  /// Label for ingredient not found
  ///
  /// In en, this message translates to:
  /// **'Oops 😵‍💫. Looks like your kitchen is empty. Add some ingredients !'**
  String get ingredientNotFound;

  /// Label for going to kitchen inventory
  ///
  /// In en, this message translates to:
  /// **'Go to inventory'**
  String get goToInventory;

  /// Label for user preference not found
  ///
  /// In en, this message translates to:
  /// **'Oops 😵‍💫. Looks like you haven\'t set your preferences yet. Head over to settings to choose them !'**
  String get userPreferenceNotFound;

  /// Label for going to choose preferences
  ///
  /// In en, this message translates to:
  /// **'Go to choose preferences'**
  String get goToChoosePreferences;

  /// Label for profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profil;

  /// Label for chat initialization message for finding a recipe with an image
  ///
  /// In en, this message translates to:
  /// **'Looking for a recipe based on a photo?\nSend us a picture of a dish you’re craving, and we’ll show you how to make it! 🍽️'**
  String get chatInitMessageFindRecipeWithImg;

  /// Label for importing a picture
  ///
  /// In en, this message translates to:
  /// **'📁 Upload a picture'**
  String get importAPicture;

  /// Label pour le chargeur de recherche de recette avec une image
  ///
  /// In en, this message translates to:
  /// **'🔍 We\'re analyzing your photo... Looks like something delicious!\nHang tight, we\'re figuring out the dish...'**
  String get findRecipeWithImageLoader;

  /// Label for recipe found
  ///
  /// In en, this message translates to:
  /// **'🍝 Yum! This dish looks like a...'**
  String get recipeFound;

  /// Label for see more
  ///
  /// In en, this message translates to:
  /// **'See the full recipe'**
  String get seeMore;

  /// Label for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for my favorites
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// Label for see all
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @startDesc.
  ///
  /// In en, this message translates to:
  /// **'Help your path to health goals with happiness'**
  String get startDesc;

  /// Label for edit profile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
