import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import './generated/app_localizations.dart';

// 튜닝 방식 Enum
enum TrainingMethod { full, lora, qlora }

// 계산 결과를 담을 데이터 클래스
class VramCalculationResult {
  final double modelWeightsGB;
  final double gradientGB;
  final double optimizerGB;
  final double activationGB;
  final double totalGB;
  final double? trainableParams; // LoRA/QLoRA 시 학습 파라미터 수
  final String? errorMessage;

  VramCalculationResult({
    required this.modelWeightsGB,
    required this.gradientGB,
    required this.optimizerGB,
    required this.activationGB,
    required this.totalGB,
    this.trainableParams,
    this.errorMessage,
  });
}

void main() {
  runApp(const VramCalculatorApp());
}

class VramCalculatorApp extends StatelessWidget {
  const VramCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: kDebugMode,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        // CardTheme -> CardThemeData로 수정
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          color: const Color(0xFF2C2C3E),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2),
          ),
          filled: true,
          fillColor: Colors.black26,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            backgroundColor: Colors.deepPurple.shade400,
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          titleMedium: TextStyle(fontSize: 18),
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelNameController = TextEditingController();
  final _paramsController = TextEditingController(text: '7');
  final _loraRankController = TextEditingController(text: '8');
  final _loraLayersController = TextEditingController(text: '32');
  final _batchSizeController = TextEditingController(text: '1');
  final _seqLenController = TextEditingController(text: '2048');

  String _quantization = '16-bit';
  TrainingMethod _trainingMethod = TrainingMethod.full;
  bool _isAdam8bit = false;
  bool _useGradientCheckpointing = true;

  VramCalculationResult? _result;

  @override
  void dispose() {
    _modelNameController.dispose();
    _paramsController.dispose();
    _loraRankController.dispose();
    _loraLayersController.dispose();
    _batchSizeController.dispose();
    _seqLenController.dispose();
    super.dispose();
  }

  // ⭐️⭐️⭐️ [개선됨] Auto-fill 로직 강화 ⭐️⭐️⭐️
  void _autofillFromModelName() {
    final modelName = _modelNameController.text.toLowerCase();
    if (modelName.isEmpty) return;

    bool paramsFound = false;

    // 1. 특정 키워드 기반 파라미터 파싱 (Phi-3 등)
    if (modelName.contains('phi-3-mini')) {
      _paramsController.text = '3.8';
      paramsFound = true;
    } else if (modelName.contains('phi-3-small')) {
      _paramsController.text = '7';
      paramsFound = true;
    } else if (modelName.contains('phi-3-medium')) {
      _paramsController.text = '14';
      paramsFound = true;
    }

    // 2. 일반적인 'Xb' 패턴 파싱 (위에서 못 찾았을 경우)
    if (!paramsFound) {
      final paramMatch = RegExp(r'(\d+\.?\d*)b').firstMatch(modelName);
      if (paramMatch != null) {
        _paramsController.text = paramMatch.group(1)!;
      }
    }

    // 3. 시퀀스 길이 파싱 ('Xk' 패턴)
    final seqLenMatch = RegExp(r'(\d+)k').firstMatch(modelName);
    if (seqLenMatch != null) {
      final kValue = int.tryParse(seqLenMatch.group(1)!) ?? 0;
      if (kValue > 0) {
        _seqLenController.text = (kValue * 1024).toString();
      }
    }

    // 4. 정밀도 파싱
    if (modelName.contains('4bit') || modelName.contains('qlora')) {
      _quantization = '4-bit';
    } else if (modelName.contains('8bit') || modelName.contains('int8')) {
      _quantization = '8-bit';
    } else if (modelName.contains('16') ||
        modelName.contains('fp16') ||
        modelName.contains('bf16')) {
      _quantization = '16-bit';
    } else if (modelName.contains('32') || modelName.contains('fp32')) {
      _quantization = '32-bit';
    }

    // 5. 튜닝 방식 파싱
    if (modelName.contains('qlora')) {
      _trainingMethod = TrainingMethod.qlora;
    } else if (modelName.contains('lora')) {
      _trainingMethod = TrainingMethod.lora;
    }

    // setState를 호출하여 UI 갱신
    setState(() {});
  }

  void _calculateVram() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final paramsInBillions = double.tryParse(_paramsController.text) ?? 0;
    if (paramsInBillions <= 0) {
      setState(() {
        _result = VramCalculationResult(
          modelWeightsGB: 0,
          gradientGB: 0,
          optimizerGB: 0,
          activationGB: 0,
          totalGB: 0,
          errorMessage: 'Parameters must be a positive number.',
        );
      });
      return;
    }
    final totalParams = paramsInBillions * 1e9;

    final batchSize = int.tryParse(_batchSizeController.text) ?? 1;
    final seqLen = int.tryParse(_seqLenController.text) ?? 512;

    // --- Model Weights VRAM ---
    double bytesPerParam;
    if (_trainingMethod == TrainingMethod.qlora) {
      bytesPerParam = 0.5; // QLoRA uses a 4-bit base model
    } else {
      switch (_quantization) {
        case '32-bit':
          bytesPerParam = 4.0;
          break;
        case '16-bit':
          bytesPerParam = 2.0;
          break;
        case '8-bit':
          bytesPerParam = 1.0;
          break;
        case '4-bit':
          bytesPerParam = 0.5;
          break;
        default:
          bytesPerParam = 2.0;
      }
    }
    final modelWeightsBytes = totalParams * bytesPerParam;

    // --- Gradients & Optimizer States VRAM ---
    double gradientBytes = 0;
    double optimizerBytes = 0;
    double? trainableParams;
    final bytesPerOptimizerState = _isAdam8bit ? 1.0 : 4.0;

    // Estimate model architecture properties based on Llama-like scaling
    // This is a rough approximation for typical models.
    // Assumes scaling from a Llama 7B model (4096 hidden size, 32 layers).
    final hiddenSize = sqrt(paramsInBillions / 7) * 4096;
    final numLayers = (32 * sqrt(paramsInBillions / 7)).round();

    if (_trainingMethod == TrainingMethod.full) {
      trainableParams = totalParams;
      gradientBytes = trainableParams * 4; // Gradients are usually FP32
      optimizerBytes =
          trainableParams *
          bytesPerOptimizerState *
          2; // Adam has 2 states (momentum, variance)
    } else {
      // LoRA & QLoRA
      final loraRank = int.tryParse(_loraRankController.text) ?? 8;
      final loraLayers = int.tryParse(_loraLayersController.text) ?? 32;

      // LoRA trainable parameters = 2 * lora_rank * hidden_size * num_lora_layers
      // We assume LoRA is applied to all specified layers.
      trainableParams = loraLayers * (2 * hiddenSize * loraRank);

      // For LoRA, gradients are usually FP32. For QLoRA, they are often BF16.
      final gradBytesPerParam = _trainingMethod == TrainingMethod.qlora
          ? 2.0
          : 4.0;
      gradientBytes = trainableParams * gradBytesPerParam;
      optimizerBytes = trainableParams * bytesPerOptimizerState * 2;
    }

    // --- Activations VRAM ---
    // Activation memory (Bytes) ≈ Batch Size × Seq Length × Hidden Size × Num Layers × Bytes per Value
    // Activations are typically stored in FP16/BF16 during training.
    final bytesPerActivation = 2.0;
    double activationBytes =
        batchSize * seqLen * hiddenSize * numLayers * bytesPerActivation;

    if (_useGradientCheckpointing) {
      // Gradient checkpointing trades compute for memory.
      // The reduction factor is roughly 1/sqrt(num_layers), often approximated as ~0.1-0.2x.
      activationBytes *= 0.1;
    }

    final totalBytes =
        modelWeightsBytes + gradientBytes + optimizerBytes + activationBytes;
    final bytesToGB = pow(10, 9);

    setState(() {
      _result = VramCalculationResult(
        modelWeightsGB: modelWeightsBytes / bytesToGB,
        gradientGB: gradientBytes / bytesToGB,
        optimizerGB: optimizerBytes / bytesToGB,
        activationGB: activationBytes / bytesToGB,
        totalGB: totalBytes / bytesToGB,
        trainableParams: trainableParams,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAutoFillSection(),
              const SizedBox(height: 20),
              _buildSectionTitle(l10n.modelConfigTitle),
              _buildModelConfigForm(),
              const SizedBox(height: 20),
              _buildSectionTitle(l10n.trainingConfigTitle),
              _buildTrainingConfigForm(),
              if (_trainingMethod == TrainingMethod.lora ||
                  _trainingMethod == TrainingMethod.qlora) ...[
                const SizedBox(height: 20),
                _buildSectionTitle(l10n.loraConfigTitle),
                _buildLoraConfigForm(),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.calculate_outlined),
                label: Text(l10n.calculateButton),
                onPressed: _calculateVram,
              ),
              const SizedBox(height: 24),
              if (_result != null) _buildResultDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  // UI 코드는 변경 없음 (하단 생략)
  Widget _buildAutoFillSection() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quickFillOptional,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _modelNameController,
                    decoration: InputDecoration(
                      hintText: l10n.modelNameHint,
                      labelText: l10n.modelNameLabel,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.arrow_circle_down),
                  onPressed: _autofillFromModelName,
                  tooltip: l10n.autofillTooltip,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white12,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.deepPurple.shade200,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildModelConfigForm() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _paramsController,
              decoration: InputDecoration(labelText: l10n.parametersLabel),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) =>
                  (v == null || v.isEmpty || double.tryParse(v) == null)
                  ? l10n.validatorEnterNumber
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _quantization,
              decoration: InputDecoration(labelText: l10n.quantizationLabel),
              items: [
                '32-bit',
                '16-bit',
                '8-bit',
                '4-bit',
              ].map((q) => DropdownMenuItem(value: q, child: Text(q))).toList(),
              onChanged: (v) => setState(() => _quantization = v!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingConfigForm() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<TrainingMethod>(
              value: _trainingMethod,
              decoration: InputDecoration(labelText: l10n.trainingMethodLabel),
              items: [
                DropdownMenuItem(
                  value: TrainingMethod.full,
                  child: Text(l10n.methodFull),
                ),
                DropdownMenuItem(
                  value: TrainingMethod.lora,
                  child: Text(l10n.methodLora),
                ),
                DropdownMenuItem(
                  value: TrainingMethod.qlora,
                  child: Text(l10n.methodQlora),
                ),
              ],
              onChanged: (v) => setState(() => _trainingMethod = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _batchSizeController,
              decoration: InputDecoration(labelText: l10n.batchSizeLabel),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || v.isEmpty || int.tryParse(v) == null)
                  ? l10n.validatorEnterInteger
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _seqLenController,
              decoration: InputDecoration(labelText: l10n.sequenceLengthLabel),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || v.isEmpty || int.tryParse(v) == null)
                  ? l10n.validatorEnterInteger
                  : null,
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: Text(l10n.use8bitAdam),
              value: _isAdam8bit,
              onChanged: (v) => setState(() => _isAdam8bit = v),
              activeColor: Colors.deepPurple.shade300,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: Text(l10n.useGradientCheckpointing),
              subtitle: Text(l10n.gradientCheckpointingSubtitle),
              value: _useGradientCheckpointing,
              onChanged: (v) => setState(() => _useGradientCheckpointing = v),
              activeColor: Colors.deepPurple.shade300,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoraConfigForm() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _loraRankController,
              decoration: InputDecoration(labelText: l10n.loraRankLabel),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || v.isEmpty || int.tryParse(v) == null)
                  ? l10n.validatorEnterInteger
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _loraLayersController,
              decoration: InputDecoration(labelText: l10n.loraLayersLabel),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || v.isEmpty || int.tryParse(v) == null)
                  ? l10n.validatorEnterInteger
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultDisplay() {
    final l10n = AppLocalizations.of(context)!;

    if (_result!.errorMessage != null) {
      return Card(
        color: Colors.red.shade900.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _result!.errorMessage!,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.resultsTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(height: 24, thickness: 1),
            if (_trainingMethod != TrainingMethod.full &&
                _result!.trainableParams != null)
              _ResultRow(
                label: l10n.trainableParameters,
                value:
                    '${(_result!.trainableParams! / 1e6).toStringAsFixed(2)} M',
              ),
            _ResultRow(
              label: l10n.modelWeights,
              value: '${_result!.modelWeightsGB.toStringAsFixed(2)} GB',
            ),
            _ResultRow(
              label: l10n.gradients,
              value: '${_result!.gradientGB.toStringAsFixed(2)} GB',
            ),
            _ResultRow(
              label: l10n.optimizerStates,
              value: '${_result!.optimizerGB.toStringAsFixed(2)} GB',
            ),
            _ResultRow(
              label: l10n.activations,
              value: '${_result!.activationGB.toStringAsFixed(2)} GB',
            ),
            const Divider(height: 24, thickness: 1),
            _ResultRow(
              label: l10n.totalVram,
              value: '${_result!.totalGB.toStringAsFixed(2)} GB',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _ResultRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final valueStyle = isTotal
        ? textTheme.headlineSmall?.copyWith(
            color: Colors.deepPurple.shade200,
            fontWeight: FontWeight.bold,
          )
        : textTheme.bodyLarge?.copyWith(color: Colors.white70);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyLarge),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}
