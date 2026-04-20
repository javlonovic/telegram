import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';

/// Reusable avatar widget — supports network image with fallback initials.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppSpacing.avatarMd,
    this.backgroundColor,
  });

  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color get _fallbackColor => backgroundColor ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (_, __) => _buildInitials(),
                errorWidget: (_, __, ___) => _buildInitials(),
              )
            : _buildInitials(),
      ),
    );
  }

  Widget _buildInitials() {
    return Container(
      width: size,
      height: size,
      color: _fallbackColor,
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
