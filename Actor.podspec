Pod::Spec.new do |spec|
  spec.name         = "Actor"
  spec.version      = "0.1.4"
  spec.summary      = "Simple implementation of the actor model."
  spec.description  = <<-DESC
  A simple implementation of the actor model in Swift.
                   DESC
  spec.homepage     = "https://github.com/rob-brown/actor"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Robert Brown" => "ammoknight@gmail.com" }
  spec.platform     = :ios, "10.0"
  spec.source       = { :git => "https://github.com/rob-brown/Actor.git", :tag => spec.version }
  spec.source_files  = "Actor", "Actor/**/*.{h,swift}"
  spec.swift_version = '5.0'
end
