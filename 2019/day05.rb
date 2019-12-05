#!/usr/bin/env ruby

ary = File.read(ARGV[0]).strip.split(',').map(&:to_i)

i = -1

loop do
  modes_and_op = ary[i += 1]
  op = modes_and_op % 100
  modes = modes_and_op / 100
  case op
  when 99
    break
  when 1
    v1 = ary[i += 1]
    v1 = ary[v1] if modes % 10 == 0
    modes /= 10
    v2 = ary[i += 1]
    v2 = ary[v2] if modes % 10 == 0
    pos = ary[i += 1]
    ary[pos] = v1 + v2
  when 2
    v1 = ary[i += 1]
    v1 = ary[v1] if modes % 10 == 0
    modes /= 10
    v2 = ary[i += 1]
    v2 = ary[v2] if modes % 10 == 0
    pos = ary[i += 1]
    ary[pos] = v1 * v2
  when 3
    pos = ary[i += 1]
    ary[pos] = $stdin.gets.to_i
  when 4
    v = ary[i += 1]
    v = ary[v] if modes % 10 == 0
    puts v
  when 5
    v = ary[i += 1]
    v = ary[v] if modes % 10 == 0
    modes /= 10
    pos = ary[i += 1]
    pos = ary[pos] if modes % 10 == 0
    i = pos - 1 unless v.zero?
  when 6
    v = ary[i += 1]
    v = ary[v] if modes % 10 == 0
    modes /= 10
    pos = ary[i += 1]
    pos = ary[pos] if modes % 10 == 0
    i = pos - 1 if v.zero?
  when 7
    v1 = ary[i += 1]
    v1 = ary[v1] if modes % 10 == 0
    modes /= 10
    v2 = ary[i += 1]
    v2 = ary[v2] if modes % 10 == 0
    pos = ary[i += 1]
    ary[pos] = v1 < v2 ? 1 : 0
  when 8
    v1 = ary[i += 1]
    v1 = ary[v1] if modes % 10 == 0
    modes /= 10
    v2 = ary[i += 1]
    v2 = ary[v2] if modes % 10 == 0
    pos = ary[i += 1]
    ary[pos] = v1 == v2 ? 1 : 0
  end
end

