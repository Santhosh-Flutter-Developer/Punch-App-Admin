import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/presentation/auth/controller/app_controller.dart';
import 'package:sri_hr_admin/presentation/sidebar/widgets/nav_item.dart';

class NavTile extends StatelessWidget {
  final NavItem item;
  final AppController app;
  final bool exp;
  const NavTile({
    super.key,
    required this.item,
    required this.app,
    required this.exp,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sel = app.currentRoute.value == item.route;
      return Padding(
        padding: const EdgeInsets.only(bottom: 1),
        child: Tooltip(
          message: exp ? '' : item.title,
          preferBelow: false,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () {
                app.currentRoute.value = item.route;
                Get.toNamed(item.route);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: EdgeInsets.symmetric(
                  horizontal: exp ? 12 : 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? const Color(0xFF3B82F6).withOpacity(0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: sel
                      ? Border.all(
                          color: const Color(0xFF3B82F6).withOpacity(0.22),
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 19,
                      color: sel ? const Color(0xFF60A5FA) : Colors.white38,
                    ),
                    if (exp) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: sel ? Colors.white : Colors.white54,
                            fontSize: 12.5,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (sel)
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF60A5FA),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
