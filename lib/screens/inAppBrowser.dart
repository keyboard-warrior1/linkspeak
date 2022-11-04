import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../widgets/common/settingsBar.dart';

class InAppBrowser extends StatefulWidget {
  final dynamic url;
  const InAppBrowser(this.url);

  @override
  State<InAppBrowser> createState() => _InAppBrowserState();
}

class _InAppBrowserState extends State<InAppBrowser> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false),
      android: AndroidInAppWebViewOptions(useHybridComposition: true),
      ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true));

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(color: Colors.blue),
        onRefresh: () async {
          if (Platform.isAndroid) {
            webViewController?.reload();
          } else if (Platform.isIOS) {
            webViewController?.loadUrl(
                urlRequest: URLRequest(url: await webViewController?.getUrl()));
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    String displayName = widget.url;
    if (displayName.length > 25)
      displayName = '${widget.url.substring(0, 25).trim()}..';
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(children: <Widget>[
          SettingsBar(displayName),
          Expanded(
              child: Stack(children: [
            InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
                initialOptions: options,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                androidOnPermissionRequest:
                    (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                onLoadStop: (controller, url) async {
                  pullToRefreshController.endRefreshing();
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onLoadError: (controller, url, code, message) {
                  pullToRefreshController.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                    urlController.text = this.url;
                  });
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                }),
            progress < 1.0
                ? LinearProgressIndicator(
                    color: _primaryColor,
                    backgroundColor: _accentColor,
                    value: progress)
                : Container(),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    color: Colors.transparent,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                              style: ButtonStyle(
                                  splashFactory: NoSplash.splashFactory,
                                  backgroundColor:
                                      MaterialStateProperty.all<Color?>(
                                          _primaryColor)),
                              child: const Icon(Icons.arrow_back),
                              onPressed: () {
                                webViewController?.goBack();
                              }),
                          ElevatedButton(
                              style: ButtonStyle(
                                  splashFactory: NoSplash.splashFactory,
                                  backgroundColor:
                                      MaterialStateProperty.all<Color?>(
                                          _primaryColor)),
                              child: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                webViewController?.goForward();
                              }),
                          ElevatedButton(
                              style: ButtonStyle(
                                  splashFactory: NoSplash.splashFactory,
                                  backgroundColor:
                                      MaterialStateProperty.all<Color?>(
                                          _primaryColor)),
                              child: const Icon(Icons.refresh),
                              onPressed: () {
                                webViewController?.reload();
                              })
                        ])))
          ]))
        ])));
  }
}
