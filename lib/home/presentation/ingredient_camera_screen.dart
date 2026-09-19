import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Full-screen custom camera used to take a live photo of ingredients,
/// matching the "Photo des ingrédients" design. Pops the captured (or
/// gallery-picked) [File], or null if the user cancels.
class IngredientCameraScreen extends StatefulWidget {
  const IngredientCameraScreen({super.key});

  @override
  State<IngredientCameraScreen> createState() =>
      _IngredientCameraScreenState();
}

class _IngredientCameraScreenState extends State<IngredientCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  FlashMode _flashMode = FlashMode.off;
  bool _permissionDenied = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _permissionDenied = true);
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      await controller.setFlashMode(_flashMode);

      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _permissionDenied = false;
      });
    } on CameraException {
      if (mounted) setState(() => _permissionDenied = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (state == AppLifecycleState.inactive) {
      if (controller != null) {
        controller.dispose();
        _controller = null;
      }
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final nextMode = _flashMode == FlashMode.off
        ? FlashMode.torch
        : FlashMode.off;
    await controller.setFlashMode(nextMode);
    if (mounted) setState(() => _flashMode = nextMode);
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final photo = await controller.takePicture();
      if (mounted) Navigator.of(context).pop(File(photo.path));
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null && mounted) {
      Navigator.of(context).pop(File(photo.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appText = di<TranslationController>().currentLanguage;
    final controller = _controller;
    final isReady = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: cameraScreenBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Gap(8),
            _CameraHeader(title: appText.ingredientCameraTitle),
            const Gap(16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: cameraFramePlaceholderColor),
                        if (isReady)
                          FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: 1 / controller.value.aspectRatio,
                              height: 1,
                              child: CameraPreview(controller),
                            ),
                          )
                        else
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                _permissionDenied
                                    ? appText.ingredientCameraPermissionDenied
                                    : appText.ingredientCameraPlaceholder,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: poppinsFontFamily,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: cameraFramePlaceholderTextColor,
                                ),
                              ),
                            ),
                          ),
                        const IgnorePointer(
                          child: CustomPaint(
                            painter: _FrameCornersPainter(),
                            size: Size.infinite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Gap(20),
            Text(
              appText.ingredientCameraHint,
              style: TextStyle(
                fontFamily: poppinsFontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: cameraHintTextColor,
              ),
            ),
            const Gap(28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GalleryButton(
                    label: appText.ingredientCameraGallery,
                    onTap: _pickFromGallery,
                  ),
                  _ShutterButton(onTap: isReady ? _capture : null),
                  _FlashButton(
                    isOn: _flashMode != FlashMode.off,
                    onTap: isReady ? _toggleFlash : null,
                  ),
                ],
              ),
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }
}

class _CameraHeader extends StatelessWidget {
  const _CameraHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: poppinsFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Colors.white,
            ),
          ),
          Positioned(
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: cameraControlBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryButton extends StatelessWidget {
  const _GalleryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cameraFramePlaceholderColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: poppinsFontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: cameraFramePlaceholderTextColor,
          ),
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          border: Border.fromBorderSide(
            BorderSide(color: Colors.white, width: 2),
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onTap == null ? Colors.white38 : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _FlashButton extends StatelessWidget {
  const _FlashButton({required this.isOn, required this.onTap});

  final bool isOn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          border: Border.fromBorderSide(
            BorderSide(color: Colors.white54, width: 1.5),
          ),
        ),
        child: Icon(
          isOn ? Icons.flash_on : Icons.flash_off,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

/// Draws the four white corner brackets over the viewfinder frame.
class _FrameCornersPainter extends CustomPainter {
  const _FrameCornersPainter();

  static const _inset = 18.0;
  static const _length = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(
      const Offset(_inset, _inset + _length),
      const Offset(_inset, _inset),
      paint,
    );
    canvas.drawLine(
      const Offset(_inset, _inset),
      const Offset(_inset + _length, _inset),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - _inset - _length, _inset),
      Offset(size.width - _inset, _inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - _inset, _inset),
      Offset(size.width - _inset, _inset + _length),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(_inset, size.height - _inset - _length),
      Offset(_inset, size.height - _inset),
      paint,
    );
    canvas.drawLine(
      Offset(_inset, size.height - _inset),
      Offset(_inset + _length, size.height - _inset),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - _inset, size.height - _inset - _length),
      Offset(size.width - _inset, size.height - _inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - _inset, size.height - _inset),
      Offset(size.width - _inset - _length, size.height - _inset),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FrameCornersPainter oldDelegate) => false;
}
