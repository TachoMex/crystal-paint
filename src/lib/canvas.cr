require "./image"

# include "utils.h"

class Canvas
  @canvas : Image
  @selected : Color
  @background : Color
  @eraser_size = 10
  @background = Color.new(255, 255, 255)
  @selected = Color.new(0, 0, 255)
  property canvas, selected, background

  def initialize(w : Int32, h : Int32, c = Color::WHITE)
    @canvas = Image.new(w, h, c)
  end

  def width
    canvas.width
  end

  def height
    canvas.height
  end

  def render(x, y)
    @canvas.draw_at(0, 0)
  end

  def draw(y : Int32, x : Int32)
    canvas[x][y] = @selected
  rescue
    nil
  end

  def reset(c)
    canvas.map! { |_| c }
  end

  def erase(y, x)
    (-@eraser_size..@eraser_size).each do |i|
      (-@eraser_size..@eraser_size).each do |j|
        single_erase(y + i, x + j)
      end
    end
  end

  def fade(f)
    canvas.fade(f)
  end

  def single_erase(y, x)
    canvas[x][y] = background
  rescue
    nil
  end

  def bresenham_same_delta(x1, y1, x2, y2, &block : (Int32, Int32 ->))
    x1, x2, y1, y2 = x2, x1, y2, y1 if x1 > x2
    step = y1 < y2 ? 1 : -1
    (x1..x2).each do |x|
      block.call(x, y1)
      y1 += step
    end
  end

  def bresenham_delta_0(i, j, x, invert, &block : (Int32, Int32 ->))
    i, j = j, i if i > j
    (i..j).each do |k|
      invert ? block.call(x, k) : block.call(k, x)
    end
  end

  def line(x1, y1, x2, y2)
    line(x1, y1, x2, y2, nil)
  end

  def line(x1, y1, x2, y2, &block)
    line(x1, y1, x2, y2, &block)
  end

  def line(x1, y1, x2, y2, block : (Int32, Int32 ->)? = nil)
    dx = (x2 - x1).abs
    dy = (y2 - y1).abs
    action = (block ? block : ->(x : Int32, y : Int32) { draw(x, y) })
    if dy == 0
      bresenham_delta_0(x1, x2, y1, false, &action)
    elsif dx == 0
      bresenham_delta_0(y1, y2, x1, true, &action)
    elsif dx == dy
      bresenham_same_delta(x1, y1, x2, y2, &action)
    elsif dy < dx
      x1, x2, y1, y2 = x2, x1, y2, y1 if x1 > x2
      x = x1
      y = y1
      increment = (y1 < y2 ? 1 : -1)
      p = 0
      p = 2 * dy - dx
      while x != x2 || y != y2
        action.call(x, y)
        if p >= 0
          x += 1
          y += increment
          p = p + 2 * dy - 2 * dx
        else
          x += 1
          p = p + 2 * dy
        end
      end
    else
      x1, x2, y1, y2 = x2, x1, y2, y1 if y1 > y2
      y = y1
      x = x1
      increment = (x1 < x2 ? 1 : -1)
      p = 2 * dx - dy
      while y != y2 || x != x2
        action.call(x, y)
        if p > 0
          y += 1
          x += increment
          p = p + 2 * dx - 2 * dy
        else
          y += 1
          p = p + 2 * dx
        end
      end
      action.call(x2, y2)
    end
  end

  def rectangle(x1, y1, x2, y2)
    line(x1, y1, x1, y2)
    line(x1, y1, x2, y1)
    line(x1, y2, x2, y2)
    line(x2, y1, x2, y2)
  end

  def filled_rectangle(x1, y1, x2, y2)
    x1, x2 = x2, x1 if x1 > x2
    (x1..x2).each do |x|
      line(x, y1, x, y2)
    end
  end

  def fill(x, y)
    return if canvas[y][x] == @selected
    target = canvas[y][x]
    dx = [1, -1, 0, 0] of Int32
    dy = [0, 0, 1, -1] of Int32
    draw(x, y)
    stack = [] of Int32
    stack.push(x)
    stack.push(y)

    until stack.empty?
      y = stack.last
      stack.pop
      x = stack.last
      stack.pop
      dx.zip(dy).each do |dx, dy|
        x2 = x + dx
        y2 = y + dy
        if @canvas[y2][x2] == target
          draw(x2, y2)
          stack.push(x2)
          stack.push(y2)
        end
      end
    end
  end

  def ellipse(h, k, a, b)
    x = 0
    y = b
    a2 = a**2
    b2 = b**2
    p = (b2 - a2 * b + 0.25 * a2).to_i
    draw(h + x, (k + y).to_i)
    draw(h - x, (k + y).to_i)
    draw(h + x, (k - y).to_i)
    draw(h - x, (k - y).to_i)
    while x * b2 < y * a2
      if p < 0
        p = p + 2 * x * b2 + b2
      else
        y -= 1
        p = (p + 2.0 * x * b2 + b2 - 2.0 * y * a2).to_i
      end
      x += 1
      draw(h + x, (k + y).to_i)
      draw(h - x, (k + y).to_i)
      draw(h + x, (k - y).to_i)
      draw(h - x, (k - y).to_i)
    end

    p = (b2 * (x + 0.5)**2 + a2 * (y - 1)**2 - a2 * b2).to_i
    while y > 0
      if p > 0
        y -= 1
        p = p - 2 * a2 * y + a2
      else
        x += 1
        y -= 1
        p = (p + 2.0 * b2 * x - 2.0 * a2 * y + a2).to_i
      end
    end
    draw(h + x, (k + y).to_i)
    draw(h - x, (k + y).to_i)
    draw(h + x, (k - y).to_i)
    draw(h - x, (k - y).to_i)
  end

  def polygon(x, y, r, ang, l)
    h = (r * Math.cos(ang)).to_i
    k = (r * Math.sin(ang)).to_i
    (1..l).each do |i|
      p = (r * Math.cos(i * (2.0 * Math::PI / l) + ang)).to_i
      q = (r * Math.sin(i * (2.0 * Math::PI / l) + ang)).to_i
      line(h + x, k + y, p + x, q + y)
      h = p
      k = q
    end
  end

  def circle_points(h, k, x, y)
    draw(h + x, (k + y).to_i)
    draw(h - x, (k + y).to_i)
    draw(h + x, (k - y).to_i)
    draw(h - x, (k - y).to_i)
    draw((h + y).to_i, k + x)
    draw((h - y).to_i, k + x)
    draw((h + y).to_i, k - x)
    draw((h - y).to_i, k - x)
  end

  def circle(h, k, r)
    x = 0
    y = r
    p = 1 - r

    circle_points(h, k, x, y)

    while x < y
      x += 1
      if p < 0
        p += 2 * x + 1
      else
        y -= 1
        p += 2 * (x - y) + 1
      end
      circle_points(h, k, x, y)
    end
  end

  def star(x, y, r, ang, l, inner_polygon = 0.5)
    s = (r * Math.cos(Math::PI / l + ang) * inner_polygon).to_i
    t = (r * Math.sin(Math::PI / l + ang) * inner_polygon).to_i
    (1..l).each do |i|
      p = (r * Math.cos(i * (2.0 * Math::PI / l) + ang)).to_i
      q = (r * Math.sin(i * (2.0 * Math::PI / l) + ang)).to_i
      line(s + x, t + y, p + x, q + y)
      s = (r * Math.cos((2.0 * i + 1.0) * Math::PI / l + ang) * inner_polygon).to_i
      t = (r * Math.sin((2.0 * i + 1.0) * Math::PI / l + ang) * inner_polygon).to_i
      line(s + x, t + y, p + x, q + y)
      h = p
      k = q
    end
  end

  def heart(x, y, a, b)
    iterations = 100
    t = 0
    h = (a * (Math.sin(t))**3).to_i
    k = (((13 * Math.cos(t) - 5 * Math.cos(2 * t) - 2 * Math.cos(3 * t) - Math.cos(4 * t) + 2.5) / 29 + 0.5) * b).to_i
    (0..iterations).each do |i|
      p = (a * (Math.sin(t))**3).to_i
      q = (((13 * Math.cos(t) - 5 * Math.cos(2 * t) - 2 * Math.cos(3 * t) - Math.cos(4 * t) + 2.5) / 29 + 0.5) * b).to_i
      line(x + h, y + k, x + p, y + q)
      h = p
      k = q
      t += 2 * Math::PI / iterations
    end
  end

  def spline_curve(x1, y1, x2, y2, x3, y3, x4, y4)
    p = x1.to_i
    q = y1.to_i
    (0..1).step(1.0/45).each do |t|
      t2 = t * t
      t3 = t2 * t
      x = ((1 - t)**3 * x1 + 3 * t * (1 - t)**2 * x3 + 3 * t2 * (1 - t) * x4 + t3 * x2).to_i
      y = ((1 - t)**3 * y1 + 3 * t * (1 - t)**2 * y3 + 3 * t2 * (1 - t) * y4 + t3 * y2).to_i
      line(p, q, x, y)
      p = x
      q = y
    end
  end

  def load_bmp(name)
    @canvas = Image.load_bmp(name)
  end

  def save_bmp(name)
    canvas.save_bmp(name)
  end
end
# endif  // CANVAS_H_
