import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/models/complaint_model.dart';
import '../../../core/theme/app_theme.dart';

class LocationPicker extends StatefulWidget {
  final LocationData? currentLocation;
  final Function(LocationData?) onLocationChanged;

  const LocationPicker({
    super.key,
    required this.currentLocation,
    required this.onLocationChanged,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  bool _isLoading = false;

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Location permissions are permanently denied');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final location = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: 'Current Location',
      );

      widget.onLocationChanged(location);
    } catch (e) {
      _showError('Failed to get location: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: _isLoading
          ? const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Getting current location...'),
        ],
      )
          : widget.currentLocation != null
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text('Current Location'),
              const Spacer(),
              TextButton(
                onPressed: _getCurrentLocation,
                child: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Lat: ${widget.currentLocation!.latitude.toStringAsFixed(6)}, '
                'Lng: ${widget.currentLocation!.longitude.toStringAsFixed(6)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      )
          : Column(
        children: [
          const Icon(Icons.location_off, color: Colors.red),
          const SizedBox(height: 8),
          const Text('Location not available'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            child: const Text('Get Location'),
          ),
        ],
      ),
    );
  }
}