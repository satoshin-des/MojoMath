from mojo_math.Matrix import Matrix

fn main() raises:
    var s = Matrix(10, 10)
    print(s)
    print(s.norm())
    s.set_random(-10, 10)
    print(s)
    
    print(s.at(90, 3))
