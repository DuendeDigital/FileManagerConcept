import 'package:flutter/material.dart';
import 'package:keepit/features/auth/screens/auth_screen.dart';
import 'package:keepit/features/auth/screens/forgot_password.dart';
import 'package:keepit/features/auth/screens/otp_screen.dart';
import 'package:keepit/features/auth/screens/register_screen.dart';
import 'package:keepit/features/auth/screens/reset_password.dart';
import 'package:keepit/features/view_files/all_files.dart';
import 'package:keepit/features/view_files/all_downloads.dart';
import 'package:keepit/features/view_files/audio.dart';
import 'package:keepit/features/view_files/docs.dart';
import 'package:keepit/features/view_files/images.dart';
import 'package:keepit/features/view_files/videos.dart';
import 'package:keepit/features/settings/screens/settings.dart';
import 'package:keepit/features/keep_it_pro/keepit_pro.dart';
import 'package:keepit/features/home/sorted_files.dart';
import 'package:keepit/features/home/dashboard.dart';
import 'package:keepit/features/loader/loader.dart';
import 'package:keepit/features/splash/screens/splash_screen.dart';
import 'package:keepit/features/Collections/screens/keepitcollections.dart';
import 'package:keepit/features/takeover_ad/fallback_ad.dart';
import 'package:keepit/features/takeover_ad/video_ad.dart';
import 'package:keepit/features/payments/payments.dart';
import 'package:keepit/features/payments/subscription.dart';

import 'features/NewFiles/new_files_modal.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case AuthScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AuthScreen(),
      );

    case All.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const All(),
      );

    case Downloads.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Downloads(),
      );

    case Audio.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Audio(),
      );

    case Docs.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Docs(),
      );

    case Images.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Images(),
      );

    case Videos.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Videos(),
      );

    case Settings.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Settings(),
      );

    case Keepitcollections.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Keepitcollections(),
      );

    case Keep_It_Pro.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Keep_It_Pro(),
      );

    // SORTED FILES
    case "${Sorted_Files.routeName}@keep":
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Sorted_Files(0),
      );
    case "${Sorted_Files.routeName}@keepFor":
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Sorted_Files(1),
      );
    case "${Sorted_Files.routeName}@bin":
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Sorted_Files(2),
      );
    // SORTED FILES

    case HomeScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const HomeScreen(),
      );

    case SplashScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SplashScreen(),
      );

    case PaymentScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const PaymentScreen(),
      );

    case SubscriptionScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SubscriptionScreen(),
      );

    case Register.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Register(),
      );

    case LoaderScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const LoaderScreen(),
      );

    case Keepitcollections.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => Keepitcollections(),
      );

    case VideoAd.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => VideoAd(
          data: '',
        ),
      );

    case Fallback.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Fallback(),
      );

    case ForgotPassword.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ForgotPassword(),
      );

    case ResetPasswordScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ResetPasswordScreen(value: ''),
      );

    case OTP.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const OTP(value: ''),
      );

    case new_files.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => new_files(),
      );

    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('404 Not Found.'),
          ),
        ),
      );
  }
}
