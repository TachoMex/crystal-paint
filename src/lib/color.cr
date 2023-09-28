class Color
  @r : UInt8
  @g : UInt8
  @b : UInt8

  property r, g, b

  def initialize(x = 0, y = 0, z = 0)
    @r = Math.min(255, Math.max(0, x)).to_u8
    @g = Math.min(255, Math.max(0, y)).to_u8
    @b = Math.min(255, Math.max(0, z)).to_u8
  end

  def clone
    Color.new(@r, @g, @b)
  end

  def +(o : self)
    rn = r + o.r
    gn = g + o.g
    bn = b + o.b
    Color.new(rn, gn, bn)
  end

  def -(o : self)
    rn = r - o.r
    gn = g - o.g
    bn = b - o.b
    Color.new(rn, gn, bn)
  end

  def to_s
    "Color{#{@r}, #{@g}, #{@b}}"
  end

  def ==(o : self)
    return r == o.r && g == o.g && b == o.b
  end

  def *(s)
    rn = s * r
    gn = s * g
    bn = s * b
    Color.new(rn, gn, bn)
  end

  def to_gray
    c = light
    Color.new(c, c, c)
  end

  def light
    (0.30 * r + 0.59 * g + 0.11 * b).to_u8
  end

  WHITE  = Color.new(255, 255, 255)
  BLACK  = Color.new(0, 0, 0)
  GREEN  = Color.new(0, 255, 0)
  BLUE   = Color.new(0, 0, 255)
  RED    = Color.new(255, 0, 0)
  YELLOW = Color.new(255, 255, 0)

  def self.from_stream(stream)
    Color.new(read_bit(stream), read_bit(stream), read_bit(stream))
  end

  def self.read_bit(stream)
    str = stream.gets(1)
    raise "Invalid Stream" if str.nil?
    str.chars.first.ord
  end

  def self.from_stream_bgr(stream)
    b, g, r = read_bit(stream), read_bit(stream), read_bit(stream)
    Color.new(r, g, b)
  end

  def write_to(stream)
    array = [@r, @g, @b]
    ptr = array.to_unsafe.as(UInt8*)
    stream.write(ptr.to_slice(array.size * sizeof(UInt8)))
  end

  def write_to_bgr(stream)
    array = [@b, @g, @r]
    ptr = array.to_unsafe.as(UInt8*)
    stream.write(ptr.to_slice(array.size * sizeof(UInt8)))
  end

  def self.max(a : Color, b : Color)
    c = Color.new
    c.r = (a.r > b.r ? a.r : b.r)
    c.g = (a.g > b.g ? a.r : b.g)
    c.b = (a.r > b.b ? a.b : b.b)
    c
  end

  def self.min(a : Color, b : Color)
    c = Color.new
    c.r = (a.r < b.r ? a.r : b.r)
    c.g = (a.g < b.g ? a.r : b.g)
    c.b = (a.r < b.b ? a.b : b.b)
    c
  end

  def self.absdif(a : Color, b : Color)
    max(a, b) - min(a, b)
  end

  def self.hsl(angle)
    angle = (angle % 360 + 360) % 360
    hue = (255 * (angle % 60) / 60.0).to_i
    hue_compliment = 255.0 - hue
    case angle // 60 % 6
    when 0
      Color.new(255, hue, 0)
    when 1
      Color.new(hue_compliment, 255, 0)
    when 2
      Color.new(0, 255, hue)
    when 3
      Color.new(0, hue_compliment, 255)
    when 4
      Color.new(hue, 0, 255)
    when 5
      Color.new(255, 0, hue_compliment)
    else
      BLACK # this block is unreacheable
    end
  end

  def gl_set
    LibGL.color_3ub(@r, @g, @b)
  end
end
