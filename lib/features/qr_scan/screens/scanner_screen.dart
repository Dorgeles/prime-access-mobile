import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;
  bool _isFetchingPosition = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner QR Code')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return _buildErrorScreen(error);
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Text(
                'Placez le QR code dans le cadre',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          if (_isFetchingPosition) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 24),
            Text(
              'Récupération de votre position...\nVeuillez patienter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned || _isFetchingPosition) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final rawValue = barcode.rawValue!;
    if (rawValue.isEmpty) return;

    _hasScanned = true;
    _controller.stop();

    _getPositionAndNavigate(rawValue);
  }

  Future<void> _getPositionAndNavigate(String qrData) async {
    setState(() => _isFetchingPosition = true);

    final permission = await Geolocator.checkPermission();

    LocationPermission effectivePermission = permission;
    if (permission == LocationPermission.denied) {
      effectivePermission = await Geolocator.requestPermission();
    }

    if (effectivePermission == LocationPermission.denied ||
        effectivePermission == LocationPermission.deniedForever) {
      setState(() {
        _isFetchingPosition = false;
        _hasScanned = false;
      });
      if (mounted) {
        _showPermissionDeniedDialog();
      }
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isFetchingPosition = false;
        _hasScanned = false;
      });
      if (mounted) {
        _showLocationServiceDisabledDialog();
      }
      return;
    }

    String lat;
    String lng;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      lat = position.latitude.toString();
      lng = position.longitude.toString();
    } catch (_) {
      lat = '0.0';
      lng = '0.0';
    }

    if (mounted) {
      context.pushReplacement('/scan/confirm', extra: {
        'qrData': qrData,
        'latitude': lat,
        'longitude': lng,
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.location_off, size: 48, color: Colors.red),
        title: const Text('Localisation requise'),
        content: const Text(
          'L\'accès à votre position GPS est nécessaire pour enregistrer '
          'vos mouvements et garantir le bon fonctionnement de l\'application.\n\n'
          'Veuillez autoriser l\'accès à la localisation dans les paramètres '
          'de votre appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Geolocator.openAppSettings();
            },
            child: const Text('Ouvrir les paramètres'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.location_disabled, size: 48, color: Colors.orange),
        title: const Text('GPS désactivé'),
        content: const Text(
          'Le service de localisation (GPS) est désactivé sur votre appareil. '
          'Il est nécessaire pour enregistrer vos mouvements correctement.\n\n'
          'Veuillez activer le GPS dans les paramètres de votre appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Geolocator.openLocationSettings();
            },
            child: const Text('Activer le GPS'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(MobileScannerException error) {
    final message = error.errorCode == MobileScannerErrorCode.permissionDenied
        ? 'L\'accès à la caméra est refusé.\n'
              'Veuillez autoriser la caméra dans les paramètres de votre appareil.'
        : error.errorCode.message;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
