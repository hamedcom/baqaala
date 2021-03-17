import 'package:baqaala/src/providers/app_provider.dart';
import 'package:baqaala/src/providers/auth_provider.dart';
import 'package:baqaala/src/providers/cart_provider.dart';
import 'package:baqaala/src/providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'src/providers/location_provider.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
  ...dependentServices,
];

List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider.value(value: LocationProvider.instance),
  ChangeNotifierProvider.value(value: CartProvider.instance),
  ChangeNotifierProvider.value(value: WalletProvider.instance),
  ChangeNotifierProvider.value(value: AuthModel.instance()),
];

List<SingleChildWidget> dependentServices = [
  ChangeNotifierProvider.value(value: AppSettingsProvider.instance),
];
