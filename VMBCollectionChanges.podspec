Pod::Spec.new do |s|
  s.name         = "VMBCollectionChanges"
  s.version      = "1.0"
  s.license      = { :type => 'MIT' }
  s.summary      = "Library provides a way to diff two datasets & get data necessary for incremental table/collection view updates"
  s.homepage     = "https://github.com/VoltMobi/VMBCollectionChanges"
  s.author       = { "VoltMobi" => "hello@voltmobi.com" }
  s.source       = { :git => "https://github.com/VoltMobi/VMBCollectionChanges.git", :tag => "#{s.version}" }
  s.source_files = "CollectionChanges/VMB*.{h,m}"
  s.public_header_files = "CollectionChanges/VMB*.h"
  s.requires_arc = true
  s.dependency 'VMBArrayDiff', '~> 1.0'
end
