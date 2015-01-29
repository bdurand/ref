#!/usr/bin/env ruby

require 'ref'
require 'benchmark'

REF_CLASSES = [
  Ref::SoftReference,
  Ref::WeakReference
]

NUM = 500_000

def version
  if defined? Ref::VERSION
    Ref::VERSION
  else
    gem_dir = Gem::Specification.find_by_name('ref').gem_dir
    File.open(File.join(gem_dir, 'VERSION'), 'r').read
  end
rescue
  'unknown'
end

puts "~~~ Ruby version: #{RUBY_VERSION}"
if defined? JRUBY_VERSION
  puts "~~~ JRuby version: #{JRUBY_VERSION}"
else
  puts "~~~ Ruby engine: #{RUBY_ENGINE}"
end
puts "~~~ Gem version: #{version}"

Benchmark.bm do |stats|

  REF_CLASSES.each do |clazz|

    puts "Benchmarking #{clazz}..."

    ref = clazz.new('foo')
    value = nil

    stats.report do
      NUM.times { value = ref.object }
    end
  end
end

__END__

~~~ Ruby version: 1.9.3
~~~ JRuby version: 1.7.18
~~~ Gem version: 1.0.5
       user     system      total        real
Benchmarking Ref::SoftReference...
   0.270000   0.010000   0.280000 (  0.114000)
Benchmarking Ref::WeakReference...
   0.080000   0.000000   0.080000 (  0.029000)

~~~ Ruby version: 1.9.3
~~~ JRuby version: 1.7.18
~~~ Gem version: 2.0.0.pre1
       user     system      total        real
Benchmarking Ref::SoftReference...
   1.020000   0.040000   1.060000 (  0.410000)
Benchmarking Ref::WeakReference...
   0.200000   0.020000   0.220000 (  0.165000)

~~~ Ruby version: 2.2.0
~~~ Ruby engine: ruby
~~~ Gem version: 2.0.0.pre1
       user     system      total        real
Benchmarking Ref::SoftReference...
   0.610000   0.000000   0.610000 (  0.621205)
Benchmarking Ref::WeakReference...
   0.120000   0.000000   0.120000 (  0.113426)

~~~ Ruby version: 2.1.0
~~~ Ruby engine: rbx
~~~ Gem version: 2.0.0.pre1
       user     system      total        real
Benchmarking Ref::SoftReference...
   1.725505   0.007228   1.732733 (  0.922712)
Benchmarking Ref::WeakReference...
   0.167794   0.001500   0.169294 (  0.088065)
