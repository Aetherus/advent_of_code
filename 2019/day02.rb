orig = File.read(ARGV[0]).strip.split(',').map(&:to_i)

100.times do |noun|
  100.times do |verb|
    ary = orig.dup
    ary[1], ary[2] = noun, verb

    i = -1

    loop do
      op = ary[i += 1]
      case op
      when 99
        break
      when 1
        pos1 = ary[i += 1]
        pos2 = ary[i += 1]
        pos3 = ary[i += 1]
        ary[pos3] = ary[pos1] + ary[pos2]
      when 2
        pos1 = ary[i += 1]
        pos2 = ary[i += 1]
        pos3 = ary[i += 1]
        ary[pos3] = ary[pos1] * ary[pos2]
      end
    end
    p(100 * noun + verb) and break if ary[0] == 19690720
  end
end

