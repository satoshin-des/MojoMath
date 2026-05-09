from mojo_math.Matrix import Matrix

fn main() raises:
    var A = Matrix(10, 10)
    A.set_random(-10, 10)
    A.round_to_int()
    print("A=", A)
    print("tr(A)=", A.trace())
    print("||A||=", A.norm())
    print("sum(A)=", A.sum())    
    print("prod(A)=", A.prod())
    print("mean(A)=", A.mean())
    print("A^T=", A.transpose())
    