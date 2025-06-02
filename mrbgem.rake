MRuby::Gem::Specification.new("mruby-bin-subnautical_intrusion") do |spec|
  spec.author  = "cyberarm"
  spec.license = "MIT"
  spec.summary = "subnautical_intrusion command"

  # spec.cc.defines << "-mwindows"
  # spec.cxx.defines << "-mwindows"
  # spec.linker.link_options << "SUBSYSTEM:WINDOWS"

  spec.bins = %w(subnautical_intrusion)
  spec.add_dependency("mruby-compiler", :core => "mruby-compiler")
end
