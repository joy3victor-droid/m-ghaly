//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audio_session
import file_picker_darwin
import file_selector_macos
import just_audio
import video_player_avfoundation
import video_trimmer

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioSessionPlugin.register(with: registry.registrar(forPlugin: "AudioSessionPlugin"))
  FilePickerPlugin.register(with: registry.registrar(forPlugin: "FilePickerPlugin"))
  FileSelectorPlugin.register(with: registry.registrar(forPlugin: "FileSelectorPlugin"))
  JustAudioPlugin.register(with: registry.registrar(forPlugin: "JustAudioPlugin"))
  VideoPlayerPlugin.register(with: registry.registrar(forPlugin: "VideoPlayerPlugin"))
  VideoTrimmerNativePlugin.register(with: registry.registrar(forPlugin: "VideoTrimmerNativePlugin"))
}
