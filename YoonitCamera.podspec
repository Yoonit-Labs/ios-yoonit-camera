
Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "YoonitCamera"
  spec.version      = "2.7.0"
  spec.summary      = "The most advanced and modern Camera module for iOS with a lot of awesome features"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
  "The most advanced and modern Camera module for iOS with a lot of awesome features"
                   DESC

  spec.homepage     = "https://github.com/Yoonit-Labs/ios-yoonit-camera"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #
  
    spec.license      = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  spec.authors = { 'CyberLabs.AI'   => 'contato@cyberlabs.ai',
                   'Luigui Delyer'  => 'luigui.delyer@cyberlabs.com.br',
                   'Haroldo Teruya' => 'haroldo.teruya@cyberlabs.com.br' }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # spec.platform     = :ios
  spec.platform     = :ios, "14.1"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  spec.source = { :git => "https://github.com/Yoonit-Labs/ios-yoonit-camera.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  spec.source_files  = "YoonitCamera/src/**/*", "Classes", "Classes/**/*.{h,m,swift}"
  
  spec.exclude_files = "Classes/Exclude"
  
  spec.swift_version = "5.0"
  
  spec.static_framework = true
  
  spec.dependency 'YoonitFacefy'
  
  spec.pod_target_xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '${SRCROOT}/**',
    'FRAMEWORK_SEARCH_PATHS' => '${SRCROOT}/**',
    'HEADER_SEARCH_PATHS' => '${SRCROOT}/**'
  }
end

