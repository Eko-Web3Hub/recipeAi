import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/receipe_item_controller.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Full-screen step-by-step cooking flow, matching 12-mode-cuisine.html.
/// Ends on a completion screen (13-termine.html) once the last step is
/// acknowledged.
class CookModeScreen extends StatefulWidget {
  const CookModeScreen({
    super.key,
    required this.receipe,
    required this.userReceipeV2,
  });

  final Receipe receipe;
  final UserReceipeV2 userReceipeV2;

  @override
  State<CookModeScreen> createState() => _CookModeScreenState();
}

class _CookModeScreenState extends State<CookModeScreen> {
  int _currentStepIndex = 0;
  bool _finished = false;

  void _goToPreviousStep() {
    setState(() => _currentStepIndex -= 1);
  }

  void _goToNextStepOrFinish() {
    if (_currentStepIndex == widget.receipe.steps.length - 1) {
      setState(() => _finished = true);
    } else {
      setState(() => _currentStepIndex += 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _finished || _currentStepIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_finished && _currentStepIndex > 0) {
          _goToPreviousStep();
        }
      },
      child: Scaffold(
        backgroundColor:
            _finished ? Colors.white : recipeLoaderInkColor,
        body: SafeArea(
          child: _finished
              ? _CookModeFinishedView(userReceipeV2: widget.userReceipeV2)
              : _CookModeStepView(
                  step: widget.receipe.steps[_currentStepIndex],
                  stepIndex: _currentStepIndex,
                  stepCount: widget.receipe.steps.length,
                  onClose: () => context.pop(),
                  onPrevious:
                      _currentStepIndex > 0 ? _goToPreviousStep : null,
                  onNext: _goToNextStepOrFinish,
                ),
        ),
      ),
    );
  }
}

class _CookModeStepView extends StatelessWidget {
  const _CookModeStepView({
    required this.step,
    required this.stepIndex,
    required this.stepCount,
    required this.onClose,
    required this.onPrevious,
    required this.onNext,
  });

  final ReceipeStep step;
  final int stepIndex;
  final int stepCount;
  final VoidCallback onClose;
  final VoidCallback? onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final isLastStep = stepIndex == stepCount - 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
              Row(
                children: List.generate(stepCount, (i) {
                  return Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                    child: Container(
                      width: 26,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: i == stepIndex
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                }),
              ),
              Text(
                '${stepIndex + 1}/$stepCount',
                style: TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${appTexts.cookModeStepLabel} ${stepIndex + 1}',
                  style: const TextStyle(
                    fontFamily: robotoSlabFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: recipeCookModeAccentColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  step.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: robotoSlabFontFamily,
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
                if (step.duration != null) ...[
                  const SizedBox(height: 24),
                  _StepTimerChip(
                    key: ValueKey(stepIndex),
                    rawDuration: step.duration!,
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Row(
            children: [
              Expanded(
                child: _CookModeSecondaryButton(
                  label: appTexts.cookModePrevious,
                  onTap: onPrevious,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CookModePrimaryButton(
                  label:
                      isLastStep ? appTexts.cookModeFinish : appTexts.cookModeNextStep,
                  onTap: onNext,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Duration? _parseStepDuration(String raw) {
  final parts = raw.trim().split(':');
  if (parts.length != 2) return null;
  final minutes = int.tryParse(parts[0]);
  final seconds = int.tryParse(parts[1]);
  if (minutes == null || seconds == null) return null;
  return Duration(minutes: minutes, seconds: seconds);
}

class _StepTimerChip extends StatefulWidget {
  const _StepTimerChip({super.key, required this.rawDuration});

  final String rawDuration;

  @override
  State<_StepTimerChip> createState() => _StepTimerChipState();
}

class _StepTimerChipState extends State<_StepTimerChip> {
  Timer? _timer;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    final parsed = _parseStepDuration(widget.rawDuration);
    _remaining = parsed;
    if (parsed != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          final remaining = _remaining!;
          _remaining = remaining.inSeconds <= 1
              ? Duration.zero
              : remaining - const Duration(seconds: 1);
        });
        if (_remaining == Duration.zero) {
          _timer?.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remaining;
    final label = remaining == null
        ? widget.rawDuration
        : '${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 16, color: recipeCookModeAccentColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: robotoFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CookModePrimaryButton extends StatelessWidget {
  const _CookModePrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: recipeCookModeAccentColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: recipeLoaderInkColor,
          ),
        ),
      ),
    );
  }
}

class _CookModeSecondaryButton extends StatelessWidget {
  const _CookModeSecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(alpha: onTap == null ? 0.12 : 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: Colors.white.withValues(alpha: onTap == null ? 0.3 : 1),
          ),
        ),
      ),
    );
  }
}

class _CookModeFinishedView extends StatefulWidget {
  const _CookModeFinishedView({required this.userReceipeV2});

  final UserReceipeV2 userReceipeV2;

  @override
  State<_CookModeFinishedView> createState() => _CookModeFinishedViewState();
}

class _CookModeFinishedViewState extends State<_CookModeFinishedView> {
  int _rating = 0;

  void _showComingSoon(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appTexts.recipeDetailsComingSoon,
          style: TextStyle(fontFamily: robotoFontFamily),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocProvider(
      create: (_) => ReceipeItemController(
        widget.userReceipeV2,
        di<IUserRecipeService>(),
        di<IAnalyticsRepository>(),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: recipeLoaderGreenColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 22),
              Text(
                appTexts.cookModeFinishedTitle,
                style: const TextStyle(
                  fontFamily: robotoSlabFontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 23,
                  color: recipeLoaderInkColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                appTexts.cookModeFinishedSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  height: 1.5,
                  color: recipeLoaderInkColor.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < _rating;
                  return InkWell(
                    onTap: () => setState(() => _rating = i + 1),
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        filled ? Icons.star : Icons.star_border,
                        size: 24,
                        color: filled
                            ? recipeLoaderGreenColor
                            : recipeLoaderInkColor.withValues(alpha: 0.2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<ReceipeItemController, ReceipeItemState>(
                  builder: (context, state) {
                    final saved = state is ReceipeItemStateSaved;
                    return _CookModePrimaryButton(
                      label: saved
                          ? appTexts.cookModeAddedToFavorites
                          : appTexts.cookModeAddToFavorites,
                      onTap: () =>
                          context.read<ReceipeItemController>().toggleFavorite(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: _CookModeGhostButton(
                  label: appTexts.recipeDetailsMarkAsCooked,
                  onTap: () => _showComingSoon(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CookModeGhostButton extends StatelessWidget {
  const _CookModeGhostButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: recipeLoaderGreenColor,
          ),
        ),
      ),
    );
  }
}
