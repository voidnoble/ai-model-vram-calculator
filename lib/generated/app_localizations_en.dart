// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Model VRAM Calculator';

  @override
  String get quickFillOptional => 'Quick Fill (Optional)';

  @override
  String get modelNameHint => 'e.g., microsoft/Phi-3-mini-4k-instruct';

  @override
  String get modelNameLabel => 'Model Name';

  @override
  String get autofillTooltip => 'Auto-fill from name';

  @override
  String get modelConfigTitle => 'Model Configuration';

  @override
  String get parametersLabel => 'Parameters (in Billions)';

  @override
  String get validatorEnterNumber => 'Enter a valid number';

  @override
  String get quantizationLabel => 'Quantization / Precision';

  @override
  String get trainingConfigTitle => 'Training Configuration';

  @override
  String get trainingMethodLabel => 'Training Method';

  @override
  String get methodFull => 'Full Fine-Tuning';

  @override
  String get methodLora => 'LoRA';

  @override
  String get methodQlora => 'QLoRA';

  @override
  String get batchSizeLabel => 'Batch Size (per GPU)';

  @override
  String get validatorEnterInteger => 'Enter a valid integer';

  @override
  String get sequenceLengthLabel => 'Sequence Length';

  @override
  String get use8bitAdam => 'Use 8-bit Adam Optimizer';

  @override
  String get useGradientCheckpointing => 'Use Gradient Checkpointing';

  @override
  String get gradientCheckpointingSubtitle => 'Reduces activation memory';

  @override
  String get loraConfigTitle => 'LoRA Configuration';

  @override
  String get loraRankLabel => 'LoRA Rank (r)';

  @override
  String get loraLayersLabel => 'Number of LoRA Layers';

  @override
  String get calculateButton => 'Calculate VRAM';

  @override
  String get resultsTitle => 'Calculation Breakdown';

  @override
  String get trainableParameters => 'Trainable Parameters';

  @override
  String get modelWeights => '1. Model Weights';

  @override
  String get gradients => '2. Gradients';

  @override
  String get optimizerStates => '3. Optimizer States';

  @override
  String get activations => '4. Activations';

  @override
  String get totalVram => 'Total Estimated VRAM';
}
