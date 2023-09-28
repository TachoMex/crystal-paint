require "./line"

module Tools
  class Circle < Line
    def draw(x, y)
      dx = x - @last_x
      dy = y - @last_y
      radius = (dx * dx + dy * dy)**0.5
      @canvas.circle(@last_x, @last_y, radius)
    end
  end
end
