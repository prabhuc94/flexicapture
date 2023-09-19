#ifndef FLUTTER_PLUGIN_FLEXICAPTURE_PLUGIN_H_
#define FLUTTER_PLUGIN_FLEXICAPTURE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flexicapture {

class FlexicapturePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlexicapturePlugin();

  virtual ~FlexicapturePlugin();

  // Disallow copy and assign.
  FlexicapturePlugin(const FlexicapturePlugin&) = delete;
  FlexicapturePlugin& operator=(const FlexicapturePlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flexicapture

#endif  // FLUTTER_PLUGIN_FLEXICAPTURE_PLUGIN_H_
