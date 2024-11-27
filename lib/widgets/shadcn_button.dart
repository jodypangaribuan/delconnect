import 'package:flutter/material.dart';

class ShadcnButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isPrimary;
  final bool isLoading;

  const ShadcnButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: !isLoading ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFF18181B) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: isPrimary ? null : Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPrimary ? Colors.white : Colors.black,
                      ),
                    ),
                  )
                : DefaultTextStyle(
                    style: TextStyle(
                      color: isPrimary ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    child: child,
                  ),
          ),
        ),
      ),
    );
  }
}
