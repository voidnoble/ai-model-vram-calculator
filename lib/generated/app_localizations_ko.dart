// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'AI 모델 VRAM 계산기';

  @override
  String get quickFillOptional => '빠른 채우기 (선택)';

  @override
  String get modelNameHint => '예: microsoft/Phi-3-mini-4k-instruct';

  @override
  String get modelNameLabel => '모델명';

  @override
  String get autofillTooltip => '이름으로 자동 채우기';

  @override
  String get modelConfigTitle => '모델 구성';

  @override
  String get parametersLabel => '파라미터 (단위: 십억)';

  @override
  String get validatorEnterNumber => '유효한 숫자를 입력하세요';

  @override
  String get quantizationLabel => '양자화 / 정밀도';

  @override
  String get trainingConfigTitle => '학습 구성';

  @override
  String get trainingMethodLabel => '학습 방식';

  @override
  String get methodFull => '전체 파인튜닝';

  @override
  String get methodLora => 'LoRA';

  @override
  String get methodQlora => 'QLoRA';

  @override
  String get batchSizeLabel => '배치 크기 (GPU 당)';

  @override
  String get validatorEnterInteger => '유효한 정수를 입력하세요';

  @override
  String get sequenceLengthLabel => '시퀀스 길이';

  @override
  String get use8bitAdam => '8비트 Adam 옵티마이저 사용';

  @override
  String get useGradientCheckpointing => '그래디언트 체크포인팅 사용';

  @override
  String get gradientCheckpointingSubtitle => '활성화 메모리 사용량 감소';

  @override
  String get loraConfigTitle => 'LoRA 구성';

  @override
  String get loraRankLabel => 'LoRA 순위 (r)';

  @override
  String get loraLayersLabel => 'LoRA 레이어 수';

  @override
  String get calculateButton => 'VRAM 계산하기';

  @override
  String get resultsTitle => '계산 내역';

  @override
  String get trainableParameters => '학습 가능한 파라미터';

  @override
  String get modelWeights => '1. 모델 가중치';

  @override
  String get gradients => '2. 그래디언트';

  @override
  String get optimizerStates => '3. 옵티마이저 상태';

  @override
  String get activations => '4. 활성화';

  @override
  String get totalVram => '총 예상 VRAM';
}
