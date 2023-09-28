require "./polygon"

module Tools
  class Star < Polygon
    @inner = 0.4

    def draw(x, y)
      dx = x - @last_x
      dy = y - @last_y
      radius = (dx * dx + dy * dy)**0.5
      @canvas.star(@last_x, @last_y, radius, 0, @sides, @inner)
    end
  end
end
