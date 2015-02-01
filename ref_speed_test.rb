#!/usr/bin/env ruby

require 'ref'
require 'benchmark'

REF_CLASSES = [
  Ref::SoftReference,
  Ref::WeakReference
]

NUM = 500_000
WARM_UPS = 50

def jruby?
  defined? JRUBY_VERSION
end

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
if jruby?
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

    puts 'Before JVM warm-up...' if jruby?
    stats.report do
      NUM.times { value = ref.object }
    end

    if jruby?
      WARM_UPS.times { value = ref.object }

      puts 'After JVM warm-up...'
      stats.report do
        NUM.times { value = ref.object }
      end
    end
  end
end

__END__

$ jruby --server ref_speed_test.rb
~~~ Ruby version: 1.9.3
~~~ JRuby version: 1.7.18
~~~ Gem version: 1.0.5
user     system      total        real
Benchmarking Ref::SoftReference...
  Before JVM warm-up...
  0.160000   0.000000   0.160000 (  0.072000)
After JVM warm-up...
  0.150000   0.010000   0.160000 (  0.087000)
Benchmarking Ref::WeakReference...
  Before JVM warm-up...
  0.050000   0.000000   0.050000 (  0.025000)
After JVM warm-up...
   0.050000   0.000000   0.050000 (  0.033000)



$ be jruby --server ref_speed_test.rb
~~~ Ruby version: 1.9.3
~~~ JRuby version: 1.7.18
~~~ Gem version: 2.0.0.pre1
       user     system      total        real
Benchmarking Ref::SoftReference...
Before JVM warm-up...
   0.990000   0.020000   1.010000 (  0.521000)
After JVM warm-up...
   0.390000   0.010000   0.400000 (  0.236000)
Benchmarking Ref::WeakReference...
Before JVM warm-up...
   0.200000   0.000000   0.200000 (  0.121000)
After JVM warm-up...
   0.060000   0.000000   0.060000 (  0.059000)



$ be ruby ref_speed_test.rb
~~~ Ruby version: 2.2.0
~~~ Ruby engine: ruby
~~~ Gem version: 2.0.0.pre1
       user     system      total        real
Benchmarking Ref::SoftReference...
   1.070000   0.000000   1.070000 (  1.066836)
Benchmarking Ref::WeakReference...
   0.160000   0.000000   0.160000 (  0.162876)



$ be ruby ref_speed_test.rb
~~~ Ruby version: 2.1.0
~~~ Ruby engine: rbx
~~~ Gem version: 2.0.0.pre1
       user     system      total        real
Benchmarking Ref::SoftReference...
   2.852072   0.012584   2.864656 (  1.673675)
Benchmarking Ref::WeakReference...
   0.287896   0.001336   0.289232 (  0.154698)
