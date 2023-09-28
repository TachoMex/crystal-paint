require "./line"

module Tools
  class Polygon < Line
    @sides = 5

    def draw(x, y)
      dx = x - @last_x
      dy = y - @last_y
      radius = (dx * dx + dy * dy)**0.5
      @canvas.polygon(@last_x, @last_y, radius, 0, @sides)
    end
  end
end
