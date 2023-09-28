require "./color"

class Image
  property pixels, width, height
  @width : Int32
  @height : Int32

  def initialize(@width = 0, @height = 0, default_color = Color::BLACK)
    @pixels = Array.new(height) { Array.new(width) { default_color } }
  end

  def initialize(other : Image)
    @pixels = other.pixels.clone
    @width = other.width
    @height = other.height
  end

  def initialize(@pixels : Array(Array(Color)))
    @width = @pixels[0].size
    @height = @pixels.size
  end

  def rows
    @height
  end

  def cols
    @width
  end

  def [](i)
    @pixels[i]
  end

  def []=(i, val)
    @pixels[i] = val
  end

  def gray_scale
    map &.to_gray
  end

  def x_derivative
    ret = Image.new(width, height)
    (0...height).each do |i|
      ret[i][0] = self[i][0]
      (1...@width).each do |j|
        ret[i][j] = Color.absdif(self[i][j], self[i][j - 1])
      end
    end
    ret
  end

  def y_derivative
    ret = Image.new(width, height)
    (0...width).each do |i|
      ret[0][i] = self[0][i]
      (1...height).each do |j|
        ret[j][i] = Color.absdif(self[j][i], self[j - 1][i])
      end
    end
    ret
  end

  def derivative
    x = x_derivative()
    y = y_derivative()
    ret = Image.new(width, height)
    ret.pixels = x.pixels.zip(y.pixels).map { |r1, r2| r1.zip(r2).map { |a, b| Color.max(a, b) } }
    ret
  end

  # Image threshold(unsigned char min = 128, Color down = Color())
  #         ret = Image.new(width, height)
  #         b = ret.begin()
  #         for (a : *this)
  #                 *b++ = (a.light() > min ? a : down)
  #         end
  #         return ret
  # end

  # Image threshold(unsigned char min, Color down, Color up)
  #         ret = Image.new(width, height)
  #         b = ret.begin()
  #         for (a : *this)
  #                 *b++ = (a.light() > min ? up : down)
  #         end
  #         return ret
  # end

  # void copy(const Image &o)
  #         memcpy(pixels, o.pixels, @width * height_ * sizeof(Color))
  # end

  # void copy(const Image &o, h, k)
  #         for (i = 0 i < o.height_ i++)
  #                 for (j = 0 j < o.@width j++)
  #                         p, q
  #                         p = h + i
  #                         q = k + j
  #                         try {
  #                                 at(p, q) = o.[i][j]
  #                         endcatch(e)end
  #                 end
  # end

  # void fade(double f)
  #         for ( a : *this)
  #                 a = a * f
  #         end
  # end

  def map
    Image.new(@pixels.map { |row| row.map { |c| yield(c) } })
  end

  def draw_at(h, k)
    LibGL.begin(LibGL::PrimitiveType::Points)
    (0...@height).each do |i|
      (0...@width).each do |j|
        p = h + i
        q = k + j
        c = self[i][j]
        c.gl_set
        LibGL.vertex_2i(q, p)
      end
    end
    LibGL.end
  end

  # ~Image()
  #         delete pixels
  # end

  # Image operator=(Image i)
  #         delete pixels
  #         @width = i.@width
  #         height_ = i.height_
  #         pixels = new Color[@width * height_]
  #         memcpy(pixels, i.pixels, @width * height_ * sizeof(Color))
  #         return i
  # end

  # Image matrix_filter(double filter[3][3])
  #         Image ret(*this)
  #         (0...width).each do |i|
  #                 for (j = 0 j < height_ j++)
  #                         double sr = 0
  #                         double sg = 0
  #                         double sb = 0
  #                         for (k = -1 k < 2 k++)
  #                                 for (l = -1 l < 2 l++)
  #                                         a = j + k, b = i + l
  #                                         if (a >= 0 && b >= 0 && b < @width && a < height_)
  #                                                 Color aux = at(a, b)
  #                                                 sr += static_cast<double>(aux.r * filter[k + 1][l + 1])
  #                                                 sg += static_cast<double>(aux.g * filter[k + 1][l + 1])
  #                                                 sb += static_cast<double>(aux.b * filter[k + 1][l + 1])
  #                                         end
  #                                 end
  #                         end
  #                         ret[j][i] = Color(sr, sg, sb)
  #                 end
  #         end
  #         return ret
  # end

  # Image gaussian_filter()
  #         double filter[3][3] = {
  #                 {1.0 / 21, 1.0 / 7, 1.0 / 21end,
  #                 {1.0 / 7, 5.0 / 21, 1.0 / 7end,
  #                 {1.0 / 21, 1.0 / 7, 1.0 / 21end
  #         end
  #         return matrix_filter(filter)
  # end

  # Image sharpen_filter()
  #         double filter[3][3] = {
  #                 {  0, -1,  0end,
  #                 {-1,  5, -1end,
  #                 {  0, -1,  0 end
  #         end
  #         return matrix_filter(filter)
  # end

  # Image blur_filter()
  #         double filter[3][3] = {
  #                 {1.0 / 9.0, 1.0 / 9.0, 1.0 / 9.0end,
  #                 {1.0 / 9.0, 1.0 / 9.0, 1.0 / 9.0end,
  #                 {1.0 / 9.0, 1.0 / 9.0, 1.0 / 9.0end
  #         end
  #         return matrix_filter(filter)
  # end

  # Image erode()
  #         ret = Image.new(width, height)
  #         dx[] = {1, -1, 0, 0end
  #         dy[] = {0, 0, 1, -1end
  #         (0...height).each do |i|
  #                 for (j = 0 j < @width j++)
  #                         Color c = [i][j]
  #                         for (k = 0 k < 4 k++)
  #                                 try {
  #                                         Color z = at(i + dy[k], j + dx[k])
  #                                         c = min(c, z)
  #                                 endcatch(e)end
  #                         end
  #                         ret.[i][j] = c
  #                 end
  #         return ret
  # end

  # Image dilate()
  #         ret = Image.new(width, height)
  #         dx[] = {1, -1, 0, 0end
  #         dy[] = {0, 0, 1, -1end
  #         (0...height).each do |i|
  #                 for (j = 0 j < @width j++)
  #                         Color c = [i][j]
  #                         for (k = 0 k < 4 k++)
  #                                 try {
  #                                         Color z = at(i + dy[k], j + dx[k])
  #                                         c = max(c, z)
  #                                 endcatch(e)end
  #                         end
  #                         ret.[i][j] = c
  #                 end
  #         return ret
  # end

  # Image laplace()
  #         double filter[3][3] = {
  #                 {  -1, -1,  -1end,
  #                 {-1,  8, -1end,
  #                 {  -1, -1,  -1 end
  #         end
  #         return matrix_filter(filter)
  # end

  def write_bits(stream, n : T) forall T
    array = [n]
    ptr = (array.to_unsafe.as UInt8*)
    stream.write(ptr.to_slice(array.size * sizeof(T)))
  end

  macro read_bits(type)
    f.read_bytes({{ type }}, IO::ByteFormat::LittleEndian)
  end

  def draw_at(o : Image, x, y)
    (0...@height).each do |i|
      (0...@width).each do |j|
        o[y + i][x + j] = self[i][j]
      rescue
        nil
      end
    end
  end

  def region(p, q, h, k)
    r = Image.new(h, k)
    (0...k).each do |i|
      (0...h).each do |j|
        r[i][j] = self[q + i][p + j]
      rescue
        nil
      end
    end
    r
  end

  def save_bmp(path)
    f = File.open(path, "w")
    f.print("BM")
    write_bits(f, 54i32 + @width * @height)
    write_bits(f, 0i32)
    write_bits(f, 0x36i32) # offset
    write_bits(f, 40i32)   # header_size
    write_bits(f, @width)
    write_bits(f, @height)
    write_bits(f, 1i16)  # planes
    write_bits(f, 24i16) # bits
    write_bits(f, 0i32)  # compression
    write_bits(f, 0i32)  # palete size
    write_bits(f, 0i32)  # bpi x
    write_bits(f, 0i32)  # bpi y
    write_bits(f, 0i32)  # used colors
    write_bits(f, 0i32)  # important colors

    fixture = (4 - (@width * 3) % 4) % 4
    (0...@height).each do |i|
      (0...@width).each do |j|
        self[i][j].write_to_bgr(f)
      end
      (0...fixture).each do |j|
        write_bits(f, 0i8)
      end
    end
    f.close
  end

  def self.load_bmp(path)
    f = File.open(path, "r")
    raise "Invalid BMP Headers" if f.gets(1) != "B" || f.gets(1) != "M"
    size = read_bits(Int32)
    read_bits(Int32) # reserved
    header_size = read_bits(Int32)
    read_bits(Int32) # offset
    width = read_bits(Int32)
    height = read_bits(Int32)
    read_bits(Int16) # planes
    read_bits(Int16) # bits
    read_bits(Int32) # Compresion
    read_bits(Int32) # Tamaño Paleta
    read_bits(Int32) # BitsPorMetroX
    read_bits(Int32) # BitsPorMetroY
    read_bits(Int32) # Colores Usados
    read_bits(Int32) # Colores Importantes
    img = Image.new(width, height)
    fixture = (4 - (width * 3) % 4) % 4
    f.seek(header_size, IO::Seek::Set)
    (0...height).each do |i|
      (0...width).each do |j|
        img.pixels[i][j] = Color.from_stream_bgr(f)
      end
      (0...fixture).each do |j|
        read_bits(Int8)
      end
    end
    f.close
    img
  end
end

# Image region(p, q, h, k, Image& r)
#         delete r.pixels
#         r.height_ = k
#         r.pixels = new Color[h * k]

#         for (i = 0 i < k i++)
#                 for (j = 0 j <h j++)
#                         try {
#                                 r.[i][j] = at(q + i, p + j)
#                         endcatch(e)end
#         return r
# end

#     #ifdef GL_H
# void gl_read()
#         delete pixels
#         @width = glutGet(GLUT_WINDOW_WIDTH)
#         height_ = glutGet(GLUT_WINDOW_HEIGHT)
#         pixels = new Color[@width * height_]
#         glReadPixels(0, 0, @width, height_, GL_RGB, GL_UNSIGNED_BYTE, pixels)
# end

# void gl_read(x2, y2)
#         delete pixels
#         @width = x2
#         height_ = y2
#         pixels = new Color[@width * height_]
#         glReadPixels(0, 0, x, y, GL_RGB, GL_UNSIGNED_BYTE, pixels)
# end

# void gl_draw()
#         glDrawPixels(x, y, GL_RGB, GL_UNSIGNED_BYTE, pixels)
# end
#     #endif  # GL_H
# end

# #endif  # IMAGE_H_
