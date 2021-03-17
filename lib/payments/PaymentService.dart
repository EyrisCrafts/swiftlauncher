// class PaymentService {
//   //Singleton object
//   PaymentService._internal();
//   static final PaymentService instance = PaymentService._internal();

// // To listen the status of connection between app and the billing server
//   StreamSubscription<ConnectionResult> _connectionSubscription;

//   /// To listen the status of the purchase made inside or outside of the app (App Store / Play Store)
//   ///
//   /// If status is not error then app will be notied by this stream
//   StreamSubscription<PurchasedItem> _purchaseUpdatedSubscription;

//   /// To listen the errors of the purchase
//   StreamSubscription<PurchaseResult> _purchaseErrorSubscription;

//   /// List of product ids you want to fetch
//   final List<String> _productIds = [
//     'monthly_subscription'
//   ];

//   /// All available products will be store in this list
//   List<IAPItem> _products;

//   /// All past purchases will be store in this list
//   List<PurchasedItem> _pastPurchases;

//   /// view of the app will subscribe to this to get notified
//   /// when premium status of the user changes
//   ObserverList<Function> _proStatusChangedListeners =
//       new ObserverList<Function>();

//   /// view of the app will subscribe to this to get errors of the purchase
//   ObserverList<Function(String)> _errorListeners =
//       new ObserverList<Function(String)>();

//   /// logged in user's premium status
//   bool _isProUser = false;

//   bool get isProUser => _isProUser;
// /// view can subscribe to _proStatusChangedListeners using this method
//   addToProStatusChangedListeners(Function callback) {
//     _proStatusChangedListeners.add(callback);
//   }
//   /// view can cancel to _proStatusChangedListeners using this method
//   removeFromProStatusChangedListeners(Function callback) {
//     _proStatusChangedListeners.remove(callback);
//   }
//   /// view can subscribe to _errorListeners using this method
//   addToErrorListeners(Function callback) {
//     _errorListeners.add(callback);
//   }
//   /// view can cancel to _errorListeners using this method
//   removeFromErrorListeners(Function callback) {
//     _errorListeners.remove(callback);
//   }

//  /// Call this method to notify all the subsctibers of _proStatusChangedListeners
//   void _callProStatusChangedListeners() {
//     _proStatusChangedListeners.forEach((Function callback) {
//       callback();
//     });
//   }

//   /// Call this method to notify all the subsctibers of _errorListeners
//   void _callErrorListeners(String error) {
//     _errorListeners.forEach((Function callback) {
//       callback(error);
//     });
//   }
//  /// Call this method at the startup of you app to initialize connection
//   /// with billing server and get all the necessary data
//   void initConnection() async {
//     await FlutterInappPurchase.instance.initConnection;
//     _connectionSubscription =
//         FlutterInappPurchase.connectionUpdated.listen((connected) {});

//     _purchaseUpdatedSubscription =
//         FlutterInappPurchase.purchaseUpdated.listen(_handlePurchaseUpdate);

//     _purchaseErrorSubscription =
//         FlutterInappPurchase.purchaseError.listen(_handlePurchaseError);

//     _getItems();
//     _getPastPurchases();
//   }
//   /// call when user close the app
//   void dispose() {
//     _connectionSubscription.cancel();
//     _purchaseErrorSubscription.cancel();
//     _purchaseUpdatedSubscription.cancel();
//     FlutterInappPurchase.instance.endConnection;
//   }
//   void _handlePurchaseError(PurchaseResult purchaseError) {
//     _callErrorListeners(purchaseError.message);
// }

//  /// Called when new updates arrives at ``purchaseUpdated`` stream
//   void _handlePurchaseUpdate(PurchasedItem productItem) async {
//     if (Platform.isAndroid) {
//       await _handlePurchaseUpdateAndroid(productItem);
//     }
//   }

// /// three purchase state https://developer.android.com/reference/com/android/billingclient/api/Purchase.PurchaseState
//   /// 0 : UNSPECIFIED_STATE
//   /// 1 : PURCHASED
//   /// 2 : PENDING
//   Future<void> _handlePurchaseUpdateAndroid(PurchasedItem purchasedItem) async {
//     switch (purchasedItem.purchaseStateAndroid) {
//       case 1:
//         if (!purchasedItem.isAcknowledgedAndroid) {
//           await _verifyAndFinishTransaction(purchasedItem);
//         }
//         break;
//       default:
//         _callErrorListeners("Something went wrong");
//     }
//   }
//  /// Call this method when status of purchase is success
//   /// Call API of your back end to verify the reciept
//   /// back end has to call billing server's API to verify the purchase token
//   _verifyAndFinishTransaction(PurchasedItem purchasedItem) async {
//     bool isValid = false;
//     try {
//       // Call API
//       isValid = await _verifyPurchase(purchasedItem);
//     } on NoInternetException {
//       _callErrorListeners("No Internet");
//       return;
//     } on Exception {
//       _callErrorListeners("Something went wrong");
//       return;
//     }

//     if (isValid) {
//       FlutterInappPurchase.instance.finishTransaction(purchasedItem);
//       _isProUser = true;
//       // save in sharedPreference here
//       _callProStatusChangedListeners();
//     } else {
//       _callErrorListeners("Varification failed");
//     }
//   }

// Future<List<IAPItem>> get products async {
//   if (_products == null) {
//     await _getItems();
//   }
//   return _products;
// }

// Future<void> _getItems() async {
//   List<IAPItem> items =
//       await FlutterInappPurchase.instance.getSubscriptions(_productIds);
//   _products = List();
//   for (var item in items) {
//     this._products.add(item);
//   }
// }
// void _getPastPurchases() async {
//     // remove this if you want to restore past purchases in iOS
//     if (Platform.isIOS) {
//       return;
//     }
//     List<PurchasedItem> purchasedItems =
//         await FlutterInappPurchase.instance.getAvailablePurchases();

//     for (var purchasedItem in purchasedItems) {
//       bool isValid = false;

//       if (Platform.isAndroid) {
//         Map map = json.decode(purchasedItem.transactionReceipt);
//           // if your app missed finishTransaction due to network or crash issue
//           // finish transactins
//         if (!map['acknowledged']) {
//           isValid = await _verifyPurchase(purchasedItem);
//           if (isValid) {
//             FlutterInappPurchase.instance.finishTransaction(purchasedItem);
//             _isProUser = true;
//             _callProStatusChangedListeners();
//           }
//         } else {
//           _isProUser = true;
//           _callProStatusChangedListeners();
//         }
//       }
//     }

//     _pastPurchases = List();
//     _pastPurchases.addAll(purchasedItems);
//   }
// Future<Null> buyProduct(IAPItem item) async {
//   try {
//     await FlutterInappPurchase.instance.requestSubscription(item.productId);
//   } catch (error) {
//   }
// }

// }
