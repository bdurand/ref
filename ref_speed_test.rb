#!/usr/bin/env ruby

require 'ref'
require 'benchmark'

REF_CLASSES = [
    Ref::SoftReference,
    Ref::WeakReference
]

NUM      = 50_000_000
WARM_UPS = NUM

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

    ref   = clazz.new('foo')
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
   2.210000   0.010000   2.220000 (  1.989000)
After JVM warm-up...
   2.390000   0.010000   2.400000 (  2.339000)
Benchmarking Ref::WeakReference...
Before JVM warm-up...
   2.210000   0.000000   2.210000 (  2.208000)
After JVM warm-up...
   2.330000   0.010000   2.340000 (  2.335000)

$ be ruby --server ref_speed_test.rb
~~~ Ruby version: 1.9.3
~~~ JRuby version: 1.7.18
~~~ Gem version: 2.0.0.pre1
       user     system      total        real
Benchmarking Ref::SoftReference...
Before JVM warm-up...
  17.230000   0.090000  17.320000 ( 16.411000)
After JVM warm-up...
  17.260000   0.050000  17.310000 ( 17.566000)
Benchmarking Ref::WeakReference...
Before JVM warm-up...
   5.820000   0.010000   5.830000 (  5.865000)
After JVM warm-up...
   5.460000   0.000000   5.460000 (  5.525000)


$ be ruby ref_speed_test.rb
~~~ Ruby version: 2.2.0
~~~ Ruby engine: ruby
~~~ Gem version: 2.0.0.pre1
       user     system      total        real
Benchmarking Ref::SoftReference...
 108.620000   0.220000 108.840000 (110.627922)
Benchmarking Ref::WeakReference...
  23.450000   0.050000  23.500000 ( 23.859564)



$ be ruby ref_speed_test.rb
~~~ Ruby version: 2.1.0
~~~ Ruby engine: rbx
~~~ Gem version: 2.0.0.pre1
       user     system      total        real
Benchmarking Ref::SoftReference...
 109.086397   0.202284 109.288681 (109.015337)
Benchmarking Ref::WeakReference...
   7.204607   0.011526   7.216133 (  7.070819)
