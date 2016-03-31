Pod::Spec.new do |s|
  s.name             = "CollieGallery"
  s.version          = "0.2.0"
  s.summary          = "Easy-to-use and highly customizable fullscreen image gallery with support for local and remote images written in Swift."

  s.description      = <<-DESC
    CollieGallery is a fullscreen image gallery with support for local and remote images and it has a lot of built-in features like zooming, panning, interactive transitions and more! The gallery is highly customizable and it’s really easy to make it look and work the way you want.
DESC

  s.homepage         = "https://github.com/gmunhoz/CollieGallery"
  s.screenshots     = "http://gmunhoz.com/public/controls/CollieGallery/screenshots/1.gif", "http://gmunhoz.com/public/controls/CollieGallery/screenshots/2.gif", "http://gmunhoz.com/public/controls/CollieGallery/screenshots/3.gif", "http://gmunhoz.com/public/controls/CollieGallery/screenshots/4.gif"
  s.license          = 'MIT'
  s.author           = { "Guilherme Munhoz" => "g.araujo.munhoz@gmail.com" }
  s.source           = { :git => "https://github.com/gmunhoz/CollieGallery.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'CollieGallery' => ['Pod/Assets/*.png']
  }
end
