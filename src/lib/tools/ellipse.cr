require "./line"

module Tools
  class Ellipse < Line
    def draw(x, y)
      dx = (x - @last_x).abs.to_f
      dy = (y - @last_y).abs.to_f
      @canvas.ellipse(@last_x, @last_y, dx, dy)
    end
  end
end
