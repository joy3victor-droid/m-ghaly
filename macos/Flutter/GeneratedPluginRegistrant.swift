//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audio_session
import ffmpeg_kit_flutter_new
import file_picker_darwin
import file_selector_macos
import gal
import just_audio
import just_waveform
import video_player_avfoundation
import video_trimmer

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioSessionPlugin.register(with: registry.registrar(forPlugin: "AudioSessionPlugin"))
  FFmpegKitFlutterPlugin.register(with: registry.registrar(forPlugin: "FFmpegKitFlutterPlugin"))
  FilePickerPlugin.register(with: registry.registrar(forPlugin: "FilePickerPlugin"))
  FileSelectorPlugin.register(with: registry.registrar(forPlugin: "FileSelectorPlugin"))
  GalPlugin.register(with: registry.registrar(forPlugin: "GalPlugin"))
  JustAudioPlugin.register(with: registry.registrar(forPlugin: "JustAudioPlugin"))
  JustWaveformPlugin.register(with: registry.registrar(forPlugin: "JustWaveformPlugin"))
  VideoPlayerPlugin.register(with: registry.registrar(forPlugin: "VideoPlayerPlugin"))
  VideoTrimmerNativePlugin.register(with: registry.registrar(forPlugin: "VideoTrimmerNativePlugin"))
}
