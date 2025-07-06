import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced LLM VRAM Calculator'**
  String get appTitle;

  /// No description provided for @quickFillOptional.
  ///
  /// In en, this message translates to:
  /// **'Quick Fill (Optional)'**
  String get quickFillOptional;

  /// No description provided for @modelNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., microsoft/Phi-3-mini-4k-instruct'**
  String get modelNameHint;

  /// No description provided for @modelNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get modelNameLabel;

  /// No description provided for @autofillTooltip.
  ///
  /// In en, this message translates to:
  /// **'Auto-fill from name'**
  String get autofillTooltip;

  /// No description provided for @modelConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Model Configuration'**
  String get modelConfigTitle;

  /// No description provided for @parametersLabel.
  ///
  /// In en, this message translates to:
  /// **'Parameters (in Billions)'**
  String get parametersLabel;

  /// No description provided for @validatorEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validatorEnterNumber;

  /// No description provided for @quantizationLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantization / Precision'**
  String get quantizationLabel;

  /// No description provided for @trainingConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Configuration'**
  String get trainingConfigTitle;

  /// No description provided for @trainingMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Training Method'**
  String get trainingMethodLabel;

  /// No description provided for @methodFull.
  ///
  /// In en, this message translates to:
  /// **'Full Fine-Tuning'**
  String get methodFull;

  /// No description provided for @methodLora.
  ///
  /// In en, this message translates to:
  /// **'LoRA'**
  String get methodLora;

  /// No description provided for @methodQlora.
  ///
  /// In en, this message translates to:
  /// **'QLoRA'**
  String get methodQlora;

  /// No description provided for @batchSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Batch Size (per GPU)'**
  String get batchSizeLabel;

  /// No description provided for @validatorEnterInteger.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid integer'**
  String get validatorEnterInteger;

  /// No description provided for @sequenceLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Sequence Length'**
  String get sequenceLengthLabel;

  /// No description provided for @use8bitAdam.
  ///
  /// In en, this message translates to:
  /// **'Use 8-bit Adam Optimizer'**
  String get use8bitAdam;

  /// No description provided for @useGradientCheckpointing.
  ///
  /// In en, this message translates to:
  /// **'Use Gradient Checkpointing'**
  String get useGradientCheckpointing;

  /// No description provided for @gradientCheckpointingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reduces activation memory'**
  String get gradientCheckpointingSubtitle;

  /// No description provided for @loraConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'LoRA Configuration'**
  String get loraConfigTitle;

  /// No description provided for @loraRankLabel.
  ///
  /// In en, this message translates to:
  /// **'LoRA Rank (r)'**
  String get loraRankLabel;

  /// No description provided for @loraLayersLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of LoRA Layers'**
  String get loraLayersLabel;

  /// No description provided for @calculateButton.
  ///
  /// In en, this message translates to:
  /// **'Calculate VRAM'**
  String get calculateButton;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculation Breakdown'**
  String get resultsTitle;

  /// No description provided for @trainableParameters.
  ///
  /// In en, this message translates to:
  /// **'Trainable Parameters'**
  String get trainableParameters;

  /// No description provided for @modelWeights.
  ///
  /// In en, this message translates to:
  /// **'1. Model Weights'**
  String get modelWeights;

  /// No description provided for @gradients.
  ///
  /// In en, this message translates to:
  /// **'2. Gradients'**
  String get gradients;

  /// No description provided for @optimizerStates.
  ///
  /// In en, this message translates to:
  /// **'3. Optimizer States'**
  String get optimizerStates;

  /// No description provided for @activations.
  ///
  /// In en, this message translates to:
  /// **'4. Activations'**
  String get activations;

  /// No description provided for @totalVram.
  ///
  /// In en, this message translates to:
  /// **'Total Estimated VRAM'**
  String get totalVram;
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
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
