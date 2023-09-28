require "../spec_helper"

describe Color do
  it "creates colors" do
    Color.new(0, 0, 0).should be_truthy
    odd = Color.new(-1, 12.3, 299)
    odd.r.should eq 0
    odd.g.should eq 12
    odd.b.should eq 255
  end

  it "allows using common operators" do
    a = Color.new(0, 128, 255)
    b = Color.new(255, 1, 0)
    c = a + b
    c.r.should eq 255
    c.g.should eq 129
    c.b.should eq 255
    a += b
    c.should eq a
    d = c.clone
    d -= b
  end

  it "allows converting color to string" do
    a = Color.new(1, 2, 3)
    a.to_s.should eq "Color{1, 2, 3}"
  end
end
