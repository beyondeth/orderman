#!/usr/bin/env ruby

# 🚀 Xcode 프로젝트 빌드 최적화 스크립트

require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

puts "🔧 Xcode 프로젝트 최적화 시작..."

project.targets.each do |target|
  target.build_configurations.each do |config|
    if config.name == 'Debug'
      # 🚀 디버그 빌드 최적화
      config.build_settings['COMPILER_INDEX_STORE_ENABLE'] = 'NO'
      config.build_settings['SWIFT_COMPILATION_MODE'] = 'singlefile'
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
      config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '0'
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
      
      # 🔥 Firestore 특화 설정
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'GRPC_ARES=0'
      
      # 시뮬레이터 최적화
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      
      puts "✅ #{target.name} - #{config.name} 설정 완료"
    end
  end
end

project.save
puts "🎉 Xcode 프로젝트 최적화 완료!"
