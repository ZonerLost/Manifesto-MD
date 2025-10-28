import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';

class CommonImageView extends StatelessWidget {
  // ignore_for_file: must_be_immutable
  String? url;
  String? imagePath;
  String? svgPath;
  File? file;
  double? height;
  double? width;
  double? radius;
  final BoxFit fit;
  final String placeHolder;
  final String? userName; // New parameter for avatar initials
  final bool isAvatar; // New parameter to indicate avatar mode

  CommonImageView({
    this.url,
    this.imagePath,
    this.svgPath,
    this.file,
    this.height,
    this.width,
    this.radius = 0.0,
    this.fit = BoxFit.cover,
    this.placeHolder = Assets.imagesCancelIcon,
    this.userName, // For avatar initials
    this.isAvatar = false, // Enable avatar mode
  });

  @override
  Widget build(BuildContext context) {
    return _buildImageView();
  }

  Widget _buildImageView() {
    // Avatar mode - show user avatar with initials fallback
    if (isAvatar) {
      return _buildAvatar();
    }

    // Original image view logic
    if (svgPath != null && svgPath!.isNotEmpty) {
      return Container(
        height: height,
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: SvgPicture.asset(
            svgPath!,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    } else if (file != null && file!.path.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: Image.file(
          file!,
          height: height,
          width: width,
          fit: fit,
        ),
      );
    } else if (url != null && url!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: url!,
          placeholder: (context, url) => Container(
            height: 23,
            width: 23,
            child: Center(
              child: SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(
                  color: kSecondaryColor,
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Image.asset(
            placeHolder,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: Image.asset(
          imagePath!,
          height: height,
          width: width,
          fit: fit,
        ),
      );
    }

    // If no image source and not in avatar mode, return avatar as fallback
    return _buildAvatar();
  }

  Widget _buildAvatar() {
    final size = height ?? width ?? 40.0;
    final avatarRadius = radius ?? (size / 2);

    // If we have a valid URL, show the network image
    if (url != null && url!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(avatarRadius),
        child: CachedNetworkImage(
          height: size,
          width: size,
          fit: BoxFit.cover,
          imageUrl: url!,
          placeholder: (context, url) => _buildInitialsAvatar(size, avatarRadius),
          errorWidget: (context, url, error) => _buildInitialsAvatar(size, avatarRadius),
        ),
      );
    }

    // Otherwise show initials avatar
    return _buildInitialsAvatar(size, avatarRadius);
  }

  Widget _buildInitialsAvatar(double size, double avatarRadius) {
    final initials = _getInitials(userName);
    final color = _getAvatarColor(userName ?? '');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(avatarRadius),
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
            fontFamily: 'Urbanist',
          ),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';

    final nameParts = name.trim().split(' ').where((part) => part.isNotEmpty).toList();

    if (nameParts.isEmpty) return 'U';
    if (nameParts.length == 1) return nameParts[0][0].toUpperCase();

    return '${nameParts[0][0]}${nameParts[nameParts.length - 1][0]}'.toUpperCase();
  }

  Color _getAvatarColor(String text) {
    final colors = [
      Color(0xFF1F7A8C), // Teal Blue
      Color(0xFFBF4E30), // Rust Red
      Color(0xFF5D8233), // Olive Green
      Color(0xFF8E6C88), // Muted Purple
      Color(0xFF2A9D8F), // Green Blue
      Color(0xFFE9C46A), // Golden Yellow
      Color(0xFFF4A261), // Sandy Brown
      Color(0xFFE76F51), // Coral
    ];

    final index = text.isNotEmpty ? text.codeUnits.reduce((a, b) => a + b) % colors.length : 0;
    return colors[index];
  }

  // Static method for quick user avatar creation (WhatsApp-style)
  static Widget userAvatar({
    String? photoUrl,
    String? userName,
    double size = 40,
    double radius = 20,
    bool showBorder = false,
  }) {
    return CommonImageView(
      url: photoUrl,
      userName: userName,
      height: size,
      width: size,
      radius: radius,
      isAvatar: true,
    );
  }

  // Static method for group member avatars (small circles like WhatsApp)
  static Widget memberAvatar({
    required String userId,
    String? photoUrl,
    String? userName,
    double size = 32,
  }) {
    return CommonImageView(
      url: photoUrl,
      userName: userName,
      height: size,
      width: size,
      radius: size / 2,
      isAvatar: true,
    );
  }

  // Static method for chat list avatars
  static Widget chatAvatar({
    String? photoUrl,
    String? userName,
    bool isGroup = false,
    double size = 50,
  }) {
    if (isGroup) {
      // For groups, you might want a different icon or style
      return CommonImageView(
        url: photoUrl,
        userName: userName,
        height: size,
        width: size,
        radius: size / 2,
        isAvatar: true,
      );
    }

    return CommonImageView(
      url: photoUrl,
      userName: userName,
      height: size,
      width: size,
      radius: size / 2,
      isAvatar: true,
    );
  }
}