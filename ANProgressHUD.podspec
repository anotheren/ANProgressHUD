Pod::Spec.new do |s|
    s.name = 'ANProgressHUD'
    s.version = '1.2.2'
    s.license = 'MIT'
    s.summary = 'ANProgressHUD'
    s.homepage = 'https://github.com/anotheren/ANProgressHUD'
    s.authors = {
        'anotheren' => 'liudong.edward@gmail.com',
    }
    s.source = { :git => 'https://github.com/anotheren/ANProgressHUD.git', :tag => s.version }
    s.ios.deployment_target = '10.0'
    s.swift_versions = ['5.0', '5.1']
    s.source_files = 'Sources/**/*.swift'
    s.frameworks = 'Foundation'
  end
